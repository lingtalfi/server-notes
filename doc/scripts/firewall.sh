#!/bin/bash



###################### reset rules
iptables -F
iptables -X


iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

#### prevent from being locked out your server
iptables -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT

###################### allow some connexions

#### icmp
iptables -A INPUT -p icmp -j ACCEPT
iptables -A OUTPUT -p icmp -j ACCEPT

#### ssh
iptables -A INPUT -p tcp --dport 22 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 22 -j ACCEPT

#### ssh-obfuscated
iptables -A INPUT -p tcp --dport 54600 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 54600 -j ACCEPT

#### dns
iptables -A OUTPUT -p udp --dport 53 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 53 -j ACCEPT

#### ntp
iptables -A OUTPUT -p udp --dport 123 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 123 -j ACCEPT

#### http
iptables -A INPUT -p tcp --dport 80 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 80 -j ACCEPT

#### https
iptables -A INPUT -p tcp --dport 443 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 443 -j ACCEPT



###################### if no previous rules matched, drop input and forward
# Notes:
# Do not set the policy to drop (do not use: iptables -P INPUT DROP),
# because otherwise, if you flush the rules, you will be locked out.
# The rule below is better: it does the same thing and you don't get locked out.
iptables -A INPUT -j DROP

