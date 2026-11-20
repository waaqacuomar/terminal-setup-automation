# My Linux Terminal Setup and VM Sweep Script

How I set up my Ubuntu workstation to manage my homelab faster, plus a script that updates and audits every VM in one pass.

## Files
- [`bashrc`](bashrc): my shell config
- [`vm-sweep.sh`](vm-sweep.sh): the VM update and audit script

## Shell (`bashrc`)
- Bash with oh-my-bash plugins (sudo, fzf, zoxide, colored man pages)
- Hand-written two-line prompt: shows a failed command's exit code, user, folder (each folder gets its own color) and git branch
- History: 10,000 lines, timestamps, no duplicates, saved after every command
- Aliases for daily work: one-word full system update, package installs, systemctl, journal errors, open ports, DNS checks
- Modern replacements when installed: eza for ls, bat for cat, ripgrep for grep, btop for top
- Safety aliases: cp, mv and rm ask before overwriting or deleting
- Functions: fuzzy folder jump (`cdf`), make-and-enter folder (`mkcd`), timestamped backup (`bak`), extract any archive (`extract`), host check (`up`), check every lab host at once (`lab`)

## VM sweep (`vm-sweep.sh`)
Runs from my main PC over SSH and writes one dated report to `~/vm-reports/`. For each VM it:
1. Runs apt update and upgrade, and flags a pending reboot
2. Counts failed and successful SSH logins in the last 24 hours, and lists the top failed-login sources
3. Shows SSH settings and warns if root can log in
4. Lists accounts that can log in, the sudo group and listening ports
5. Checks the UFW firewall and automatic security updates are on
6. Warns when the disk is over 85% full
7. Saves the last 24 hours of SSH logs

Every warning is collected in one list at the bottom of the report.

How it's built:
- Host details come from `~/.ssh/config`, so the script holds no IPs or usernames
- Key-only SSH in batch mode, so it never stops to ask for a password
- `sudo -n` means it fails cleanly instead of hanging if a VM needs a password
- Waits up to 2 minutes for the network, so it can run at boot

## Usage
```bash
cp bashrc ~/.bashrc && source ~/.bashrc
# edit HOSTS and GATEWAY at the top of vm-sweep.sh first
chmod +x vm-sweep.sh && ./vm-sweep.sh
```

## Screenshots
<!-- add: ![Terminal](images/terminal.png) -->
<!-- add: ![Sweep report](images/sweep-report.png) -->
