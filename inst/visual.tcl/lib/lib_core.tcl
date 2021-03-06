##############################################################################
# $Id: lib_core.tcl,v 1.9 1997/05/28 02:34:04 stewart Exp $
#
# lib_core.tcl - core tcl/tk widget support library
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

#
# initializes this library
#
proc vTcl:widget:lib:lib_core {args} {
    global vTcl
    foreach i {toplevel frame button entry label text listbox menubutton \
                checkbutton radiobutton scrollbar_v scrollbar_h scale_h \
                scale_v canvas menu message} {
        image create photo "ctl_$i" \
            -file [file join $vTcl(VTCL_HOME) images icon_$i.gif]
        image create photo "ctl_$i" \
            -file [file join $vTcl(VTCL_HOME) images icon_$i.gif]
    }
    foreach i {toplevel message frame canvas button entry label text \
                listbox menubutton checkbutton radiobutton scrollbar \
                scale} {
        if {$i == "scale" || $i == "scrollbar"} {
            vTcl:toolbar_add $i "horizontal ${i}" ctl_${i}_h "-orient horiz"
            vTcl:toolbar_add $i "vertical ${i}" ctl_${i}_v "-orient vert"
        } else {
            vTcl:toolbar_add $i $i ctl_$i ""
        }
    }
}

#
# Set additional attributes to set on widget-class insertion
#
set vTcl(button,insert)       "-text button"
set vTcl(canvas,insert)       "-bd 2 -relief ridge"
set vTcl(checkbutton,insert)  "-text check"
set vTcl(entry,insert)        ""
set vTcl(frame,insert)        "-bd 2 -relief groove -width 125 -height 75"
set vTcl(label,insert)        "-text label -bd 1 -relief raised"
set vTcl(listbox,insert)      ""
set vTcl(menubutton,insert)   "-text menu"
set vTcl(message,insert)      "-text message"
set vTcl(radiobutton,insert)  "-text radio"
set vTcl(scale,insert)        ""
set vTcl(scrollbar,insert)    ""
set vTcl(text,insert)         ""
set vTcl(toplevel,insert)     ""

#
# add to valid class list
#
lappend vTcl(classes) Button Canvas Checkbutton Entry Frame Label
lappend vTcl(classes) Listbox Menu Menubutton Message Radiobutton
lappend vTcl(classes) Scale Scrollbar Text Toplevel 

foreach c {Button Canvas Checkbutton Entry Frame Label
           Listbox Menu Menubutton Message Radiobutton
           Scale Scrollbar Text Toplevel} {
    # option dump procedure for a widget class
    set vTcl($c,dump_opt) vTcl:dump_widget_opt
    # whether or not to dump children of a class
    set vTcl($c,dump_children) 1
}

#
# individual widget commands executed after insert
#
proc vTcl:widget:entry:inscmd {target} {
    return "$target insert end entry"
}

proc vTcl:widget:listbox:inscmd {target} {
    return "$target insert end listbox"
}

proc vTcl:widget:menubutton:inscmd {target} {
    return "
        menu $target.m
        $target conf -menu $target.m
    "
}

proc vTcl:widget:text:inscmd {target} {
    return "$target insert end text"
}

proc vTcl:widget:toplevel:inscmd {target} {
    global vTcl
    return "
        wm protocol $target WM_DELETE_WINDOW {vTcl:hide_top $target} 
        if {$vTcl(pr,winfocus) == 1} {
            wm protocol $target WM_TAKE_FOCUS {vTcl:wm_take_focus $target} 
        }
        wm title $target \"New Toplevel $vTcl(newtops)\"
        incr vTcl(newtops)
        set vTcl(w,insert) $target
        lappend vTcl(tops) $target
        vTcl:update_top_list
    "
}

#
# per-widget action to take upon edit-mode double-click
#
proc vTcl:widget:entry:dblclick {target} {
    vTcl:set_textvar $target
}

proc vTcl:widget:message:dblclick {target} {
#    vTcl:set_label $target
}

proc vTcl:widget:label:dblclick {target} {
#    vTcl:set_label $target
}

proc vTcl:widget:button:dblclick {target} {
    vTcl:set_command $target
}

proc vTcl:widget:checkbutton:dblclick {target} {
    vTcl:set_command $target
}

proc vTcl:widget:radiobutton:dblclick {target} {
    vTcl:set_command $target
}

proc vTcl:widget:scale:dblclick {target} {
    vTcl:set_command $target
}

proc vTcl:widget:scrollbar:dblclick {target} {
    vTcl:set_command $target
}

proc vTcl:widget:menubutton:dblclick {target} {
    vTcl:edit_target_menu $target
}

proc vTcl:widget:toplevel:dblclick {target} {
    vTcl:edit_target_menu $target
}

####################################################################
# Procedure to support extra geometry mgr configuration
#

proc vTcl:grid:conf_ext {target var value} {
    global vTcl
    set parent [winfo parent $target]
    grid columnconf $parent $vTcl(w,grid,-column) -weight  $vTcl(w,grid,column,weight)
    grid columnconf $parent $vTcl(w,grid,-column) -minsize $vTcl(w,grid,column,minsize)
    grid rowconf    $parent $vTcl(w,grid,-row)    -weight  $vTcl(w,grid,row,weight)
    grid rowconf    $parent $vTcl(w,grid,-row)    -minsize $vTcl(w,grid,row,minsize)
}

proc vTcl:wm:conf_geom {target var value} {
    global vTcl
    set x $vTcl(w,wm,geometry,x)
    set y $vTcl(w,wm,geometry,y)
    set w $vTcl(w,wm,geometry,w)
    set h $vTcl(w,wm,geometry,h)
    wm geometry $target ${w}x${h}+${x}+${y}
}

proc vTcl:wm:conf_resize {target var value} {
    global vTcl
    set w $vTcl(w,wm,resizable,w)
    set h $vTcl(w,wm,resizable,h)
    wm resizable $target $w $h
}

proc vTcl:wm:conf_minmax {target var value} {
    global vTcl
    set min_x $vTcl(w,wm,minsize,x)
    set min_y $vTcl(w,wm,minsize,y)
    set max_x $vTcl(w,wm,maxsize,x)
    set max_y $vTcl(w,wm,maxsize,y)
    wm minsize $target $min_x $min_y
    wm maxsize $target $max_x $max_y
}

proc vTcl:wm:conf_state {target var value} {
    global vTcl
    wm $vTcl(w,wm,state) $target
}

proc vTcl:wm:conf_title {target var value} {
    global vTcl
    wm title $target "$vTcl(w,wm,title)"
}

####################################################################
# Procedures to support "double-click" action on widets
# There are mostly procedures to support the special case of menus
#

proc vTcl:menu_item_add {base target} {
global vTcl
    set type $vTcl(menu,$target,type)
    set label $vTcl(menu,$target,label)
    set accel $vTcl(menu,$target,accel)
    if {$label == ""} {
        set label $type
    }
    switch $type {
        separator {
            $target add $type
        }
        command -
        checkbutton -
        radiobutton {
            $target add $type -label $label -accel $accel
        }
        cascade {
            set nmenu [vTcl:new_widget_name menu $target]
            menu $nmenu
            vTcl:setup_vTcl:bind $nmenu
            $target add $type -label $label -accel $accel -menu $nmenu
        }
    }
    set list $base.fra19.lis35
    switch $type {
        separator {
            $list insert end [format "%-14s" <$type>]
        }
        default {
            $list insert end [format "%-14s %s" <$type> $label]
        }
    }
    set vTcl(menu,$target,label) ""
    set vTcl(menu,$target,accel) ""
    focus $base.fra17.ent15
}

proc vTcl:menu_item_update {base target {newpos 0}} {
global vTcl
    set list $base.fra19.lis35
    set num [$list curselection]
    if {"$num" == ""} {return}
    set type $vTcl(menu,$target,type)
    if {[$target type $num] == "tearoff"} {
        vTcl:dialog "You cannot update a cascade."
        return
    }
    if {[$target cget -tearoff]} {
        set min 1
    } else {
        set min 0
    }
    set max [expr [$list size] -1]
    set newnum [expr $num + $newpos]
    if {$newnum < $min || $newnum > $max} {return}
    if {$newpos == 0} {
        set label $vTcl(menu,$target,label)
        set accel $vTcl(menu,$target,accel)
    } else {
        set label [$target entrycget $num -label]
        set accel [$target entrycget $num -accel]
    }
    $list delete $num
    switch $type {
        separator {
            $list insert $newnum [format "%-14s" <$type>]
        }
        default {
            $list insert $newnum [format "%-14s %s" <$type> $label]
        }
    }
    if [catch {set cmd [$target entrycget $num -command]}] {
        set cmd ""
    }
    catch {set cur_menu [$target entrycget $num -menu]}
    $target delete $num
    switch $type {
        separator {
            $target insert $newnum $type
        }
        cascade {
            $target insert $newnum $type -label $label \
                -accel $accel -command $cmd -menu $cur_menu
        }
        default {
            $target insert $newnum $type -label $label \
                -accel $accel -command $cmd
        }
    }
    set vTcl(menu,$target,label) ""
    set vTcl(menu,$target,accel) ""
    $list select set $newnum
    focus $base.fra17.ent15
}

proc vTcl:menu_item_delete {base target} {
global vTcl
    set list $base.fra19.lis35
    set num [$list curselection]
    if {"$num" == ""} {return}
    set type [$target type $num]
    if {$type == "tearoff"} {
        vTcl:dialog "You cannot delete a $type.\nPlease use tearoff toggle."
        return
    }
    if {$type == "cascade"} {
        set menu [$target entrycget $num -menu]
        destroy $menu
    }
    $target delete $num
    $list delete $num
    set vTcl(menu,$target,label) ""
    set vTcl(menu,$target,accel) ""
}

proc vTcl:menu_set_tear {base target} {
    global vTcl
    $target conf -tearoff $vTcl(menu,$target,tear)
    vTcl:menu_setup $base $target
}

proc vTcl:menu_setup {base target} {
global vTcl
    set vTcl(menu,$target,name) $target
    set vTcl(menu,$target,type) "command"
    set vTcl(menu,$target,label) ""
    set vTcl(menu,$target,accel) ""
    set vTcl(menu,$target,tear) [$target cget -tearoff]
    set list $base.fra19.lis35
    $list delete 0 end
    set num [$target index end]
    if {$num != "none"} {
        for {set i 0} {$i <= $num} {incr i} {
            if [catch {set label [$target entrycget $i -label]}] {
                set label ""
            }
            set type [$target type $i]
            $list insert end [format "%-14s %s" <$type> $label]
        }
    }
}

proc vTcl:menu_item_get_cmd {target num} {
    global vTcl
    set base ".vTcl.com_[vTcl:rename $target]_$num"
    set cmd [$target entrycget $num -command]
    set lbl [$target entrycget $num -label]
    set r [vTcl:get_command "Command for $lbl ($target)" $cmd $base]
    if {$r == -1} {
        return
    } else {
        $target entryconf $num -command [string trim $r]
    }
}

proc vTcl:menu_item_act {base target} {
global vTcl
    set list $base.fra19.lis35
    set num [$list curselection]
    if {"$num" == ""} {return}
    set type [$target type $num]
    switch $type {
        cascade {
            vTcl:edit_menu [$target entrycget $num -menu]
        }
        command -
        checkbutton -
        radiobutton {
            vTcl:menu_item_get_cmd $target $num
        }
    }
}

proc vTcl:menu_item_select {base target} {
global vTcl
    set list $base.fra19.lis35
    set num [$list curselection]
    if {"$num" == ""} {return}
    set type [$target type $num]
    set vTcl(menu,$target,type) $type
    switch $type {
        cascade -
        command -
        checkbutton -
        radiobutton {
            set vTcl(menu,$target,label) [$target entrycget $num -label]
            set vTcl(menu,$target,accel) [$target entrycget $num -accel]
        }
        separator {
            set vTcl(menu,$target,type)  "$type"
            set vTcl(menu,$target,label) ""
            set vTcl(menu,$target,accel) ""
        }
        tearoff {
            set vTcl(menu,$target,type)  "command"
            set vTcl(menu,$target,label) ""
            set vTcl(menu,$target,accel) ""
        }
    }
}

proc vTcl:edit_target_menu {target} {
    global vTcl
    if [catch {set menu [$target cget -menu]}] {
        return
    }
    if {$menu == ""} {
        set menu [vTcl:new_widget_name m $target]
        menu $menu
        vTcl:setup_vTcl:bind $menu
        $target conf -menu $menu
    }
    vTcl:edit_menu $menu
}

proc vTcl:edit_menu {target} {
    global vTcl
    if {$target == ""} {return}
    vTcl:active_widget $target
    if {[winfo class $target] != "Menu"} {return}
    set name [vTcl:rename $target]
    set base ".vTcl.menu_$name"
    if {[winfo exists $base]} "
        wm deiconify $base; return
    "
    set vTcl(menu,$target,tear) 0
    set vTcl(menu,$target,name) ""
    set vTcl(menu,$target,type) ""
    set vTcl(menu,$target,label) ""
    set vTcl(menu,$target,accel) ""
    toplevel $base -class vTcl
    wm focusmodel $base passive
    wm geometry $base 255x280+221+168
    wm maxsize $base 1137 870
    wm minsize $base 1 280
    wm overrideredirect $base 0
    wm resizable $base 0 1
    wm deiconify $base
    wm title $base "Editing Menu"
    frame $base.fra16 \
        -borderwidth 2 -height 30 -relief groove -width 30 
    pack $base.fra16 \
        -anchor center -expand 0 -fill x -ipadx 0 -ipady 0 -padx 2 -pady 2 \
        -side top 
    label $base.fra16.lab20 \
        -anchor w  \
        -relief groove -text Menu -width 7 
    pack $base.fra16.lab20 \
        -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 2 -pady 2 \
        -side left 
    entry $base.fra16.ent21 \
        -highlightthickness 0 -textvariable vTcl(menu,$target,name) \
        -width 14 
    pack $base.fra16.ent21 \
        -anchor center -expand 1 -fill x -ipadx 0 -ipady 0 -padx 2 -pady 2 \
        -side left 
    frame $base.fra3 \
        -borderwidth 1 -height 30 -relief sunken -width 30 
    pack $base.fra3 \
        -anchor center -expand 0 -fill both -ipadx 0 -ipady 0 -padx 2 -pady 2 \
        -side top 
    checkbutton $base.fra3.che4 \
        -borderwidth 1 \
        -command "
            vTcl:menu_set_tear $base $target
        " \
        -highlightthickness 0 -indicatoron 0 -text {Tearoff Menu} \
        -variable vTcl(menu,$target,tear) -selectcolor #ed7291
    pack $base.fra3.che4 \
        -anchor center -expand 0 -fill both -ipadx 0 -ipady 0 -padx 2 -pady 2 \
        -side top 
    frame $base.fra17 \
        -borderwidth 1 -height 70 -relief sunken -width 30 
    pack $base.fra17 \
        -anchor center -expand 0 -fill x -ipadx 0 -ipady 0 -padx 2 -pady 2 \
        -side top 
    label $base.fra17.lab11 \
        -anchor w  \
        -relief groove -text {Entry Type} 
    place $base.fra17.lab11 \
        -x 5 -relx 0 -y 5 -rely 0 -width 75 -height 20 -anchor nw \
        -bordermode ignore 
    label $base.fra17.lab12 \
        -anchor w  \
        -relief groove -text Accelerator 
    place $base.fra17.lab12 \
        -x 5 -relx 0 -y 45 -rely 0 -width 75 -height 20 -anchor nw \
        -bordermode ignore 
    label $base.fra17.lab13 \
        -anchor w  \
        -relief groove -text {Entry Label} 
    place $base.fra17.lab13 \
        -x 5 -relx 0 -y 25 -rely 0 -width 75 -height 20 -anchor nw \
        -bordermode ignore 
    entry $base.fra17.ent15 \
        -highlightthickness 0 -textvariable vTcl(menu,$target,label) 
    place $base.fra17.ent15 \
        -x 85 -relx 0 -y 25 -rely 0 -width 161 -height 19 -anchor nw \
        -bordermode ignore 
    entry $base.fra17.ent16 \
        -highlightthickness 0 -textvariable vTcl(menu,$target,accel) 
    bind $base.fra17.ent16 <Return> "
        vTcl:menu_item_add $base $target
    "
    place $base.fra17.ent16 \
        -x 85 -relx 0 -y 45 -rely 0 -width 161 -height 19 -anchor nw \
        -bordermode ignore 
    menubutton $base.fra17.men17 \
        -borderwidth 1 \
        -menu $base.fra17.men17.m -padx 5 -pady 4 -relief raised \
        -textvariable vTcl(menu,$target,type) 
    place $base.fra17.men17 \
        -x 85 -relx 0 -y 5 -rely 0 -width 160 -height 19 -anchor nw \
        -bordermode ignore 
    menu $base.fra17.men17.m \
         -tearoff 0 
    $base.fra17.men17.m add command \
        -command "set vTcl(menu,$target,type) cascade" \
        -label cascade 
    $base.fra17.men17.m add command \
        -command "set vTcl(menu,$target,type) command" \
        -label command 
    $base.fra17.men17.m add command \
        -command "set vTcl(menu,$target,type) checkbutton" \
        -label checkbutton 
    $base.fra17.men17.m add command \
        -command "set vTcl(menu,$target,type) radiobutton" \
        -label radiobutton 
    $base.fra17.men17.m add command \
        -command "set vTcl(menu,$target,type) separator" \
        -label separator 
    frame $base.fra19 \
        -height 30 -width 30 
    pack $base.fra19 \
        -anchor center -expand 1 -fill both -ipadx 0 -ipady 0 -padx 2 -pady 2 \
        -side top 
    listbox $base.fra19.lis35 \
         -height 5 \
        -highlightthickness 0 -yscrollcommand "$base.fra19.scr36 set" \
        -exportselection 0
    pack $base.fra19.lis35 \
        -anchor center -expand 1 -fill both -ipadx 0 -ipady 0 -padx 0 -pady 0 \
        -side left 
    vTcl:set_balloon $base.fra19.lis35 "Double-Click to edit"
    bind $base.fra19.lis35 <Double-Button-1> "
        vTcl:menu_item_act $base $target
    "
    bind $base.fra19.lis35 <ButtonRelease-1> "
        vTcl:menu_item_select $base $target
    "
    bind $base <Down> "
        vTcl:menu_item_update $base $target 1
    "
    bind $base <Up> "
        vTcl:menu_item_update $base $target -1
    "
    scrollbar $base.fra19.scr36 \
        -borderwidth 1 -command "$base.fra19.lis35 yview" \
        -highlightthickness 0 -width 10 
    pack $base.fra19.scr36 \
        -anchor center -expand 0 -fill y -ipadx 0 -ipady 0 -padx 0 -pady 0 \
        -side right 
    frame $base.fra2 \
        -borderwidth 1 -height 30 -relief sunken -width 30 
    pack $base.fra2 \
        -anchor center -expand 0 -fill x -ipadx 0 -ipady 0 -padx 2 -pady 2 \
        -side top 
    button $base.fra2.01 \
        -command "vTcl:menu_item_add $base $target" \
        -highlightthickness 0 -padx 11 -pady 3 -text Add -width 4 
    pack $base.fra2.01 \
        -anchor center -expand 1 -fill both -ipadx 0 -ipady 0 -padx 2 -pady 2 \
        -side left 
    button $base.fra2.02 \
        -command "vTcl:menu_item_update $base $target" \
        -highlightthickness 0 -padx 11 -pady 3 -text Update -width 4 
    pack $base.fra2.02 \
        -anchor center -expand 1 -fill both -ipadx 0 -ipady 0 -padx 2 -pady 2 \
        -side left 
    button $base.fra2.03 \
        -command "vTcl:menu_item_delete $base $target" \
        -highlightthickness 0 -padx 11 -pady 3 -text Delete -width 4 
    pack $base.fra2.03 \
        -anchor center -expand 1 -fill both -ipadx 0 -ipady 0 -padx 2 -pady 2 \
        -side left 
    button $base.fra2.04 \
        -command "destroy $base" \
        -highlightthickness 0 -padx 11 -pady 3 -text Done -width 4 
    pack $base.fra2.04 \
        -anchor center -expand 1 -fill both -ipadx 0 -ipady 0 -padx 2 -pady 2 \
        -side left 
    vTcl:menu_setup $base $target
}

