#!/bin/bash
# Emit network status JSON for waybar's custom module.
# Resolves the active interface from the default route so it works
# regardless of interface naming or connection type (wifi/ethernet).

IFACE=$(ip route get 1.1.1.1 2>/dev/null \
    | awk '{for(i=1;i<=NF;i++) if($i=="dev") {print $(i+1); exit}}')

if [ -z "$IFACE" ]; then
    jq -cn '{text: "net [ disconnected ]", class: "disconnected", tooltip: "No network connection"}'
    exit 0
fi

IPCIDR=$(ip addr show "$IFACE" 2>/dev/null | awk '/inet / {print $2; exit}')
GATEWAY=$(ip route show default dev "$IFACE" 2>/dev/null | awk '{print $3; exit}')

if [ -d "/sys/class/net/$IFACE/wireless" ]; then
    NM=$(nmcli -t -f ACTIVE,SSID,SIGNAL dev wifi 2>/dev/null | grep '^yes:' | head -1)
    SSID=$(echo "$NM" | cut -d: -f2)
    SIGNAL=$(echo "$NM" | cut -d: -f3)

    TEXT="wifi [ ${SSID:-?} ${SIGNAL:----}% ]"
    TOOLTIP=$(printf 'WiFi: %s\nSignal: %s%%\nIP: %s\nGateway: %s' \
        "${SSID:-unknown}" "${SIGNAL:----}" "${IPCIDR:-none}" "${GATEWAY:-none}")
    CLASS="wifi"
else
    if [ -n "$IPCIDR" ]; then
        TEXT="eth [ $IFACE ]"
        TOOLTIP=$(printf 'Ethernet: %s\nIP: %s\nGateway: %s' \
            "$IFACE" "${IPCIDR:-none}" "${GATEWAY:-none}")
        CLASS="ethernet"
    else
        TEXT="eth [ $IFACE (no ip) ]"
        TOOLTIP=$(printf 'Ethernet: %s\nNo IP assigned' "$IFACE")
        CLASS="linked"
    fi
fi

jq -cn --arg text "$TEXT" --arg tooltip "$TOOLTIP" --arg class "$CLASS" \
    '{text: $text, tooltip: $tooltip, class: $class}'
