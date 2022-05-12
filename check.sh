#!/bin/bash

echo -n "CF_API_EMAIL="
read CF_API_EMAIL
echo -n "CF_API_KEY="
read CF_API_KEY

export CF_API_EMAIL
export CF_API_KEY

List() {
flarectl z l | tee check.txt
}

DNSRand() {
echo "Checking dns of 3 random domains..."

cat check.txt | grep -o [a-z]*[1-5].gq | sort -R | head -n3 > check.rand
> check.rand.log

for randDom in $(cat check.rand) 
do
	flarectl d l $randDom | tee -a check.rand.log
done
}

DNS() {
echo "Checking dns of 100 domains..."

cat check.txt | grep -o [a-z]*[1-5].gq > check.list
> check.list.log

for dom in $(cat check.list)
do
	        flarectl d l $dom | tee -a check.list.log
done
}

Checks() {
echo ""
if [[ $(grep -o [a-z]*[1-5].gq check.txt | wc -l | cut -d" " -f1) -ge "100" ]]; then
	echo -e "Domains \t- CHECK (100 domains added)"
else
	echo -e "Domains \t- Missing Domains, Please Fix"
fi

echo -e "HTTPS \t\t- CHECK (assumed, not guaranteed)" 

if [[ $(grep "pending" check.txt | grep -o [a-z]*[1-5].gq | wc -l) -eq "0" ]]; then
	echo -e "Nameserver \t- CHECK (all active)"
else
	echo -e "Nameserver \t- Please Fix"
	grep "pending" check.txt | grep -o [a-z]*[1-5].gq  
fi
}

ChecksDNSRand() {
if [[ $(wc -l check.rand.log | cut -d" " -f1) -ge "12" ]]; then
	echo -e "DNS \t\t- CHECK (not guaranteed, only checked 3 random domains)"
else
	echo -e "DNS \t\t- Please Fix Missing DNS"
fi
}

ChecksDNS() {
if [[ $(wc -l check.list.log | cut -d" " -f1) -ge "400" ]]; then
	echo -e "DNS \t\t- CHECK (all have A & CNAME)"
else
	echo -e "DNS \t\t- Please Fix Missing DNS (redo macro)"
fi
}

Start() {
read -p 'Do DNS? [r | a]

r = 3 random (Default) 
a = all

Choice selected: ' ans
case $ans in

	A | a) echo ""
                List
                DNS
                Checks
                ChecksDNS
                ;;
        *) echo ""
                List
		DNSRand
		Checks
		ChecksDNSRand
		;;
esac
}

Start
