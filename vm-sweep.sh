#!/usr/bin/env bash
# vm-sweep.sh — runs on my main PC.
# For each VM: apt update + upgrade, a security audit, and the last 24h of SSH logs.
# Everything lands in one .txt file in ~/vm-reports/
set -u

# Host aliases from ~/.ssh/config (user, IP and port come from there)
HOSTS=(vm1 vm2 vm3 vm4)

# Address to ping before starting, so the sweep waits for the network after boot
GATEWAY="your-router-ip"

OUT_DIR="$HOME/vm-reports"
mkdir -p "$OUT_DIR"
REPORT="$OUT_DIR/$(date +%F_%H%M).txt"

# After boot, wait up to 2 minutes for the network (router) to answer
for i in $(seq 1 24); do
  ping -c1 -W2 "$GATEWAY" >/dev/null 2>&1 && break
  sleep 5
done

SSH_OPTS="-o BatchMode=yes -o ConnectTimeout=10 -o StrictHostKeyChecking=accept-new"

{
  echo "VM sweep report — $(date)"
  for name in "${HOSTS[@]}"; do
    echo
    echo "==================== $name ===================="
    ssh $SSH_OPTS "$name" 'bash -s' <<'REMOTE' 2>&1 || echo "WARN: could not finish on this VM"
echo "--- UPDATE ---"
if sudo -n apt-get update -qq &&
   sudo -n apt-get -y -qq -o Dpkg::Options::=--force-confdef -o Dpkg::Options::=--force-confold upgrade; then
  echo "Update OK"
else
  echo "WARN: update failed"
fi
[ -f /var/run/reboot-required ] && echo "WARN: reboot required"

echo
echo "--- SECURITY AUDIT ---"
LOG=$(sudo -n journalctl -u ssh -u sshd --since "24 hours ago" --no-pager 2>&1)

FAILED=$(echo "$LOG" | grep -cE "Failed password|Invalid user|authentication failure")
PASSOK=$(echo "$LOG" | grep -c "Accepted password")
KEYOK=$(echo "$LOG" | grep -c "Accepted publickey")
echo "Failed SSH logins (24h): $FAILED"
[ "$FAILED" -gt 5 ] && echo "WARN: more than 5 failed SSH logins"
echo "Successful logins (24h): $KEYOK by key, $PASSOK by password"
echo "Top failed-login sources:"
echo "$LOG" | grep -E "Failed password|Invalid user" | grep -oE "from [0-9a-fA-F.:]+" | sort | uniq -c | sort -rn | head -5
echo

SSHCFG=$(cat /etc/ssh/sshd_config /etc/ssh/sshd_config.d/*.conf 2>/dev/null | grep -iE "^[[:space:]]*(PermitRootLogin|PasswordAuthentication|Port)[[:space:]]")
echo "SSH settings:"
echo "${SSHCFG:-  (all defaults)}"
echo "$SSHCFG" | grep -qiE "PermitRootLogin[[:space:]]+yes" && echo "WARN: root can log in over SSH"
echo

echo "Accounts that can log in:"
awk -F: '$7 ~ /(bash|zsh|sh|fish)$/ {print "  " $1}' /etc/passwd
echo "Admin (sudo) group: $(getent group sudo | cut -d: -f4)"
echo

echo "Listening ports:"
ss -tuln | awk 'NR>1 {print "  " $1, $5}' | sort -u
echo

if command -v ufw >/dev/null 2>&1 && systemctl is-active --quiet ufw; then
  echo "Firewall (ufw): active"
else
  echo "WARN: firewall (ufw) not active"
fi

if dpkg -s unattended-upgrades >/dev/null 2>&1; then
  echo "Automatic security updates: installed"
else
  echo "WARN: automatic security updates not installed"
fi

echo "Uptime: $(uptime -p)"
DISK=$(df -h / | awk 'NR==2 {print $5}')
echo "Disk used on /: $DISK"
[ "${DISK%\%}" -gt 85 ] && echo "WARN: disk over 85% full"

echo
echo "--- SSH LOG (last 24h) ---"
echo "$LOG"
REMOTE
  done
} > "$REPORT"

# Put every warning in one list at the bottom
{
  echo
  echo "==================== WARNINGS ===================="
  awk '/^==================== / {vm=$2} /WARN:/ {print vm ": " $0}' "$REPORT"
} >> "$REPORT"

echo "Report saved: $REPORT"
