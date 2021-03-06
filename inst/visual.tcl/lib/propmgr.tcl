##############################################################################
# $Id: propmgr.tcl,v 1.9 1997/05/05 02:02:24 stewart Exp $
#
# propmgr.tcl - procedures used by the widget properites manager
#
# Copyright (C) 1996-1997 Stewart Allen
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

##############################################################################
#

proc vTcl:grid:height {parent {col 0}} {
    update idletasks
    set h 0
    set s [grid slaves $parent -column $col]
    foreach i $s {
        incr h [winfo height $i]
    }
    return $h
}

proc vTcl:grid:width {parent {row 0}} {
    update idletasks
    set w 0
    set s [grid slaves $parent -row $row]
    foreach i $s {
        incr w [winfo width $i]
    }
    return $w
}

proc vTcl:prop:set_visible {which {on ""}} {
    global vTcl
    set var ${which}_on
    switch $which {
        info {
            set f $vTcl(gui,ae).c.f1
            set name "Widget"
        }
        attr {
            set f $vTcl(gui,ae).c.f2
            set name "Attributes"
        }
        geom {
            set f $vTcl(gui,ae).c.f3
            set name "Geometry"
        }
        default {
            return
        }
    }
    if {$on == ""} {
        set on [expr - $vTcl(pr,$var)]
    }
    if {$on == 1} {
        pack $f.f -side top -expand 1 -fill both
        $f.l conf -text "$name (-)"
        set vTcl(pr,$var) 1
    } else {
        pack forget $f.f
        $f.l conf -text "$name (+)"
        set vTcl(pr,$var) -1
    }
    update idletasks
    vTcl:prop:recalc_canvas
}

proc vTclWindow.vTcl.ae {args} {
    global vTcl tcl_platform
    set ae $vTcl(gui,ae)
    if {[winfo exists $ae]} {wm deiconify $ae; return}
    toplevel $ae -class vTcl
    wm withdraw $ae
    wm title $ae "Attribute Editor"
    wm geometry $ae 206x325
    wm resizable $ae 1 1

    canvas $ae.c -yscrollcommand "$ae.sv set" \
        -xscrollcommand "$ae.sh set" -highlightthickness 0
    scrollbar $ae.sh -orient horiz -command "$ae.c xview" -takefocus 0
    scrollbar $ae.sv -orient vert  -command "$ae.c yview" -takefocus 0

    grid $ae.c  -column 0 -row 0 -sticky news
    grid $ae.sh -column 0 -row 1 -sticky ew
    grid $ae.sv -column 1 -row 0 -sticky ns

    grid columnconf $ae 0 -weight 1
    grid rowconf    $ae 0 -weight 1

    set f1 $ae.c.f1; frame $f1       ; # Widget Info
        $ae.c create window 0 0 -window $f1 -anchor nw -tag info
    set f2 $ae.c.f2; frame $f2       ; # Widget Attributes
        $ae.c create window 0 0 -window $f2 -anchor nw -tag attr
    set f3 $ae.c.f3; frame $f3       ; # Widget Geometry
        $ae.c create window 0 0 -window $f3 -anchor nw -tag geom

    label $f1.l -text "Widget"     -relief raised -bg #aaaaaa -bd 1 -width 30
        pack $f1.l -side top -fill x
    label $f2.l -text "Attributes" -relief raised -bg #aaaaaa -bd 1 -width 30
        pack $f2.l -side top -fill x
    label $f3.l -text "Geometry"   -relief raised -bg #aaaaaa -bd 1 -width 30
        pack $f3.l -side top -fill x

    bind $f1.l <ButtonPress> {vTcl:prop:set_visible info}
    bind $f2.l <ButtonPress> {vTcl:prop:set_visible attr}
    bind $f3.l <ButtonPress> {vTcl:prop:set_visible geom}

    set w $f1.f
    frame $w; pack $w -side top -expand 1 -fill both

    label $w.ln -text "Widget" -width 11 -anchor w
        label $w.en -width 12 -textvariable vTcl(w,widget) \
        -relief sunken -bd 1 -anchor w
    label $w.lc -text "Class"  -width 11 -anchor w
        label $w.ec -width 12 -textvariable vTcl(w,class) \
        -relief sunken -bd 1 -anchor w
    label $w.lm -text "Manager" -width 11 -anchor w
        label $w.em -width 12 -textvariable vTcl(w,manager) \
        -relief sunken -bd 1 -anchor w
    label $w.la -text "Alias"  -width 11 -anchor w
        label $w.ea -width 12 -textvariable vTcl(w,alias) \
        -relief sunken -bd 1 -anchor w
    label $w.li -text "Insert Point" -width 11 -anchor w
        label $w.ei -width 12 -textvariable vTcl(w,insert) \
        -relief sunken -bd 1 -anchor w

    grid columnconf $w 1 -weight 1

    grid $w.ln $w.en -padx 0 -pady 1 -sticky news
    grid $w.lc $w.ec -padx 0 -pady 1 -sticky news
    grid $w.lm $w.em -padx 0 -pady 1 -sticky news
    grid $w.la $w.ea -padx 0 -pady 1 -sticky news
    grid $w.li $w.ei -padx 0 -pady 1 -sticky news

    set w $f2.f
    frame $w; pack $w -side top -expand 1 -fill both

    set w $f3.f
    frame $w; pack $w -side top -expand 1 -fill both

    vTcl:prop:set_visible info $vTcl(pr,info_on)
    vTcl:prop:set_visible attr $vTcl(pr,attr_on)
    vTcl:prop:set_visible geom $vTcl(pr,geom_on)

    if { $vTcl(w,widget) != "" } {
        vTcl:prop:update_attr
    }
    vTcl:setup_vTcl:bind $vTcl(gui,ae)
    if {$tcl_platform(platform) == "macintosh"} {
        set w [expr [winfo vrootwidth .] - 206]
        wm geometry $vTcl(gui,ae) 200x300+$w+20
    }
    catch {wm geometry .vTcl.ae $vTcl(geometry,.vTcl.ae)}
    update idletasks
    vTcl:prop:recalc_canvas

    wm deiconify $ae
}

proc vTcl:prop:recalc_canvas {} {
    global vTcl
    set ae $vTcl(gui,ae)
    if {![winfo exists $ae]} {return}

    set f1 $ae.c.f1                              ; # Widget Info Frame
    set f2 $ae.c.f2                              ; # Widget Attribute Frame
    set f3 $ae.c.f3                              ; # Widget Geometry Frame

    $ae.c coords attr 0 [winfo height $f1]
    $ae.c coords geom 0 [expr [winfo height $f1] + [winfo height $f2]]

    set w [vTcl:util:greatest_of "[winfo width $f1] \
                                  [winfo width $f2] \
                                  [winfo width $f3]" ]
    set h [expr [winfo height $f1] + \
                [winfo height $f2] + \
                [winfo height $f3] ]
    $ae.c configure -scrollregion "0 0 $w $h"
    wm minsize .vTcl.ae $w 200
}

proc vTcl:prop:update_attr {} {
    global vTcl
    if {$vTcl(var_update) == "no"} {
        return
    }

    #
    # Update Widget Attributes
    #
    set fr $vTcl(gui,ae).c.f2.f
    set top $fr._$vTcl(w,class)
    update idletasks
    if {[winfo exists $top]} {
        if {$vTcl(w,class) != $vTcl(w,last_class)} {
            catch {pack forget $fr._$vTcl(w,last_class)}
            pack $top -side left -fill both -expand 1
        }
        foreach i $vTcl(opt,list) {
            if {[lsearch $vTcl(w,optlist) $i] >= 0} {
                if { [lindex $vTcl(opt,$i) 2] == "color" } {
                    $top.t${i}.f configure -bg $vTcl(w,opt,$i)
                }
            }
        }
    } elseif [winfo exists $fr] {
        catch {pack forget $fr._$vTcl(w,last_class)}
        frame $top
        pack $top -side top -expand 1 -fill both
        grid columnconf $top 1 -weight 1
        set type ""
        foreach i $vTcl(opt,list) {
            set newtype [lindex $vTcl(opt,$i) 1]
            if {$type != $newtype} {
                set type $newtype
            }
            if {[lsearch $vTcl(w,optlist) $i] >= 0} {
                set variable "vTcl(w,opt,$i)"
                set config_cmd "\$vTcl(w,widget) configure $i \$$variable; "
                append config_cmd "vTcl:place_handles \$vTcl(w,widget)"
                vTcl:prop:new_attr $top $i $variable $config_cmd opt
            }
        }
    }

    if {$vTcl(w,manager) == ""} {
        update idletasks
        vTcl:prop:recalc_canvas
        return
    }

    #
    # Update Widget Geometry
    #
    set fr $vTcl(gui,ae).c.f3.f
    set top $fr._$vTcl(w,manager)
    set mgr $vTcl(w,manager)
    update idletasks
    if {[winfo exists $top]} {
        if {$vTcl(w,manager) != $vTcl(w,last_manager)} {
            catch {pack forget $fr._$vTcl(w,last_manager)}
            pack $top -side left -fill both -expand 1
        }
    } elseif [winfo exists $fr] {
        catch {pack forget $fr._$vTcl(w,last_manager)}
        frame $top
        pack $top -side top -expand 1 -fill both
        grid columnconf $top 1 -weight 1
        foreach i "$vTcl(m,$mgr,list) $vTcl(m,$mgr,extlist)" {
            set variable "vTcl(w,$mgr,$i)"
            set cmd [lindex $vTcl(m,$mgr,$i) 4]
            set config_cmd "$cmd \$vTcl(w,widget) $i \$$variable"
            if {$cmd == ""} {
                set config_cmd "$mgr conf \$vTcl(w,widget) $i \$$variable"
            }
            append config_cmd ";vTcl:place_handles \$vTcl(w,widget)"
            vTcl:prop:new_attr $top $i $variable $config_cmd m,$mgr
        }
    }

    update idletasks
    vTcl:prop:recalc_canvas
}

proc vTcl:prop:new_attr {top option variable config_cmd prefix} {
    global vTcl
    set base $top.t${option}
    label $top.$option \
        -text "[lindex $vTcl($prefix,$option) 0]" -anchor w -width 11 -fg black
    switch [lindex $vTcl($prefix,$option) 2] {
        boolean {
            frame $base
            radiobutton ${base}.y \
                -variable $variable -value 1 -text "Yes" -relief sunken -bd 1 \
                -command "$config_cmd" -selectcolor #0077ff -padx 0 -pady 1
            radiobutton ${base}.n \
                -variable $variable -value 0 -text "No" -relief sunken -bd 1 \
                -command "$config_cmd" -selectcolor #0077ff -padx 0 -pady 1
            pack ${base}.y ${base}.n -side left -expand 1 -fill both
        }
        choice {
            frame $base
            menubutton ${base}.l \
                -textvariable $variable -bd 1 -width 12 -menu ${base}.l.m \
                -highlightthickness 1 -relief sunken -anchor w -fg black \
                -padx 0 -pady 1
            menu ${base}.l.m -tearoff 0
            foreach i [lindex $vTcl($prefix,$option) 3] {
                ${base}.l.m add command -label "$i" -command \
                    "set $variable $i; $config_cmd; "
            }
            button ${base}.f -relief raised -bd 1 -image file_down \
                -height 5 -command "tkMbPost ${base}.l"
            pack ${base}.l -side left -expand 1 -fill x
            pack ${base}.f -side right -fill y -pady 1 -padx 1
        }
        menu {
            button $base \
                -text "<click to edit>" -relief sunken -bd 1 -width 12 \
                -highlightthickness 1 -fg black -padx 0 -pady 1 \
                -command {
                    vTcl:edit_target_menu $vTcl(w,widget)
                } -anchor w
        }
        color {
            frame $base
            entry ${base}.l -relief sunken -bd 1 \
                -textvariable $variable -width 8 \
                -highlightthickness 1 -fg black
            bind ${base}.l <KeyRelease-Return> \
                "$config_cmd; ${base}.f conf -bg \$$variable"
            frame ${base}.f -relief raised -bd 1 \
                -bg [subst $$variable] -width 30 -height 5
            bind ${base}.f <ButtonPress> \
                "vTcl:show_color $top.t${option}.f $option $variable"
            pack ${base}.l -side left -expand 1 -fill x
            pack ${base}.f -side right -fill y -pady 1 -padx 1
        }
        command {
            frame $base
            entry ${base}.l -relief sunken -bd 1 \
                -textvariable $variable -width 8 \
                -highlightthickness 1 -fg black
            bind ${base}.l <KeyRelease-Return> $config_cmd
            button ${base}.f \
                -image ellipses -bd 1 -width 12 \
                -highlightthickness 1 -fg black -padx 0 -pady 1 \
                -command "vTcl:set_command \$vTcl(w,widget) $option"
            pack ${base}.l -side left -expand 1 -fill x
            pack ${base}.f -side right -fill y -pady 1 -padx 1
        }
        default {
            entry $base \
                -textvariable $variable -relief sunken -bd 1 -width 12 \
                -highlightthickness 1 -fg black
        }
    }
    bind $base <KeyRelease-Return> $config_cmd
    grid $top.$option $base -sticky news
}

