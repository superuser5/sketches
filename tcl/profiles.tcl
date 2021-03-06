if {"Windows NT" != $tcl_platform(os)} {
  throw {OSERROR} {Wrong operating system.}
}

package require registry

set HKLM {HKEY_LOCAL_MACHINE}
set key  {SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList}

if {[catch {set keys [registry keys "$HKLM\\$key"]} e]} {
  puts stderr [format "\[Error\]: %s" [lindex [split $e :] 0]]
  exit 1
}

puts [format "%-15s %-43s %s" Profile Sid Path]
puts [format "%-15s %-43s %s" ------- --- ----]
foreach sid $keys {
  if {[catch {set path [registry get "$HKLM\\$key\\$sid" ProfileImagePath]}]} {
    continue ; # just move to the next entry
  }

  if {[regexp {^%(.*)%} $path _ x]} { ; # expand variable
    regsub $x [regsub -all % $path {}] $::env($x) path
  }

  set name [split $path \\]
  set name [lindex $name [expr {[llength $name] - 1}]]
  puts [format "%-15s %-43s %s" $name $sid $path]
}
