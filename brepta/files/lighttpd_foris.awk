BEGIN {
    matched = 0
}
/^\$HTTP\[\"url\"\] \!~.*$/ {
    if (matched == 0) {
        print "$HTTP[\"host\"] == \"192.168.2.1\" {\n    " $0
        matched = 1
        next
    }
}

/^}/ {
    if (matched == 1) {
        print "\t}\n}"
        next
    }
}

{ print }
