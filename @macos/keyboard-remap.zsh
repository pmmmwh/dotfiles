#!/usr/bin/env -S zsh -f

readonly BUILT_IN_KEYBOARD='{"Built-In":1,"PrimaryUsagePage":1,"PrimaryUsage":6}'

readonly SPOTLIGHT=0xC00000221
readonly F20=0x70000006F
readonly GRAVE_ACCENT=0x700000035
readonly NON_US_BACKSLASH=0x700000064

# StandardType is 0 for ANSI, 1 for ISO and 2 for JIS; hidutil cannot read it as it lives on the driver, not the service
built_in_layout() {
  /usr/sbin/ioreg -r -c AppleHIDKeyboardEventDriverV2 -l -w0 | /usr/bin/awk '
    function report() {
      if (!done && built_in && layout != "") { print layout; done = 1 }
    }
    /\+-o / { report(); built_in = 0; layout = "" }
    /"Built-In" = Yes/ { built_in = 1 }
    /"StandardType" = / { layout = $NF }
    END { report() }
  '
}

mapping() {
  print -r -- "{\"HIDKeyboardModifierMappingSrc\":$1,\"HIDKeyboardModifierMappingDst\":$2}"
}

mappings=($(mapping $SPOTLIGHT $F20))

# Apple's ISO keyboards report the section sign and grave accent keys the wrong way round relative to ANSI
if [[ $(built_in_layout) == 1 ]]; then
  mappings+=($(mapping $GRAVE_ACCENT $NON_US_BACKSLASH) $(mapping $NON_US_BACKSLASH $GRAVE_ACCENT))
fi

exec /usr/bin/hidutil property --matching $BUILT_IN_KEYBOARD --set "{\"UserKeyMapping\":[${(j:,:)mappings}]}" > /dev/null
