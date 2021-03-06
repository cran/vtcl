##############################################################################
# $Id: var.tcl,v 1.10 1997/05/30 03:55:39 stewart Exp $
#
# var.tcl - procedures for manipulating variables and the variable browser
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

proc vTcl:delete_var {var} {
global vTcl
    set name [vTcl:var_root $var]
    catch {
        global $name
        unset $var
        if { $name != $var && "[array names $name]" == "" } {
            unset $name
        }
    }
    vTcl:list delete $name vTcl(vars)
}

proc vTcl:find_new_vars {{a 0}} {
global vTcl
    update idletasks
    return [vTcl:diff_list $vTcl(start,globals) [info globals]]
}

proc vTcl:show_var {name} {
global vTcl
    if { $name != "" } {
        set globname [vTcl:var_root $name]
        global $globname
        set value [subst $$name]
        Window show .vTcl.var .vTcl.var $name $value
    } else {
        Window show .vTcl.var "" "" ""
    }
}

proc vTcl:update_var {} {
global vTcl
    set vTcl(var,name) [.vTcl.var.fra2.ent8 get]
    set vTcl(var,value) [string trimright [.vTcl.var.fra3.tex10 get 0.0 end]]
    set globname [vTcl:var_root $vTcl(var,name)]
    global $globname
    set $vTcl(var,name) $vTcl(var,value)
    vTcl:list add $globname vTcl(vars)
    grab release .vTcl.var
    destroy .vTcl.var
    vTcl:update_var_list
}

proc vTcl:update_var_list {} {
global vTcl
    if { [winfo exists $vTcl(gui,varlist)] == 0 } { return }
    $vTcl(gui,varlist).f2.list delete 0 end
    foreach i $vTcl(vars) {
        if {[vTcl:valid_varname $i] == 1} {
            catch {global $i}
            if {[array exists $i] == 1} {
                foreach j [array names $i] {
                    $vTcl(gui,varlist).f2.list insert end "$i\($j\)"
                }
            } else {
                $vTcl(gui,varlist).f2.list insert end $i
            }
        }
    }
}

proc vTcl:valid_varname {name} {
global vTcl
    if [regexp "^($vTcl(var,ignore))" $name] {
        return 0
    } else {
        return 1
    }
}

proc vTcl:var_root {name} {
set pos [string first "(" $name]
    if {$pos > -1} {
        return [string range $name 0 [expr $pos - 1]]
    } else {
        return $name
    }
}

proc vTclWindow.vTcl.var {args} {
    global vTcl
    set base [lindex $args 0]
    set name [lindex $args 1]
    set value [lindex $args 2]
    if {[winfo exists .vTcl.var]} {
        wm deiconify .vTcl.var; return
    }
    toplevel .vTcl.var -class vTcl
#    wm transient .vTcl.var .vTcl
    wm focusmodel .vTcl.var passive
    wm geometry .vTcl.var 338x136+276+319
    wm maxsize .vTcl.var 1137 870
    wm minsize .vTcl.var 1 1
    wm overrideredirect .vTcl.var 0
    wm resizable .vTcl.var 1 1
    wm deiconify .vTcl.var
    wm title .vTcl.var "Variable Editor"
    bind .vTcl.var <Key-Escape> {vTcl:update_var}
    frame .vTcl.var.fra2 \
        -height 30 -width 30 
    pack .vTcl.var.fra2 \
        -in .vTcl.var -anchor center -expand 0 -fill x -ipadx 0 -ipady 0 \
        -padx 3 -pady 3 -side top 
    label .vTcl.var.fra2.lab7 \
         \
        -relief groove -text Variable 
    pack .vTcl.var.fra2.lab7 \
        -in .vTcl.var.fra2 -anchor center -expand 0 -fill none -ipadx 0 \
        -ipady 0 -padx 2 -pady 0 -side left 
    entry .vTcl.var.fra2.ent8 \
        -cursor {}  \
        -highlightthickness 0 -textvariable vTcl(var,name) 
    pack .vTcl.var.fra2.ent8 \
        -in .vTcl.var.fra2 -anchor center -expand 1 -fill both -ipadx 0 \
        -ipady 0 -padx 2 -pady 2 -side left 
    frame .vTcl.var.fra3 \
        -borderwidth 2 -height 30 -relief groove -width 30 
    pack .vTcl.var.fra3 \
        -in .vTcl.var -anchor center -expand 1 -fill both -ipadx 0 -ipady 0 \
        -padx 3 -pady 3 -side top 
    text .vTcl.var.fra3.tex10 \
        -cursor {}  \
        -height 1 -highlightthickness 0 -width 1 \
        -yscrollcommand {.vTcl.var.fra3.scr12 set} 
    pack .vTcl.var.fra3.tex10 \
        -in .vTcl.var.fra3 -anchor center -expand 1 -fill both -ipadx 0 \
        -ipady 0 -padx 2 -pady 2 -side left 
    scrollbar .vTcl.var.fra3.scr12 \
        -command {.vTcl.var.fra3.tex10 yview}
    pack .vTcl.var.fra3.scr12 \
        -in .vTcl.var.fra3 -anchor center -expand 0 -fill y -ipadx 0 -ipady 0 \
        -padx 0 -pady 0 -side right 
    frame .vTcl.var.fra4 \
        -borderwidth 1 -height 30 -relief sunken -width 30 
    pack .vTcl.var.fra4 \
        -in .vTcl.var -anchor center -expand 0 -fill x -ipadx 0 -ipady 0 \
        -padx 3 -pady 3 -side top 
    button .vTcl.var.fra4.but5 \
        -command {
            vTcl:update_var
        } \
         -padx 9 \
        -pady 3 -text OK -width 5 
    pack .vTcl.var.fra4.but5 \
        -in .vTcl.var.fra4 -anchor center -expand 1 -fill both -ipadx 0 \
        -ipady 0 -padx 0 -pady 0 -side left 
    button .vTcl.var.fra4.but6 \
        -command {grab release .vTcl.var; destroy .vTcl.var} \
         -padx 9 \
        -pady 3 -text Cancel -width 5 
    pack .vTcl.var.fra4.but6 \
        -in .vTcl.var.fra4 -anchor center -expand 1 -fill both -ipadx 0 \
        -ipady 0 -padx 0 -pady 0 -side left 

    set varname $base.fra2.ent8
    set varvalue $base.fra3.tex10
    set vTcl(var,name) $name
    set vTcl(var,value) $value

    $varname delete 0 end
    $varvalue delete 0.0 end
    $varname insert end $name
    $varvalue insert end $value

    if { [lindex $args 1] == "" } {
        focus $varname
    } else {
        focus $varvalue
    }
}

proc vTcl:varlist:show {{on ""}} {
    global vTcl
    if {$on == "flip"} { set on [expr - $vTcl(pr,show_var)] }
    if {$on == ""}     { set on $vTcl(pr,show_var) }
    if {$on == 1} {
        Window show $vTcl(gui,varlist)
        vTcl:update_var_list
    } else {
        Window hide $vTcl(gui,varlist)
    }
    set vTcl(pr,show_var) $on
}

proc vTclWindow.vTcl.varlist {args} {
    global vTcl
    set base .vTcl.varlist
    if {[winfo exists .vTcl.varlist]} {
        wm deiconify .vTcl.varlist; return
    }
    toplevel .vTcl.varlist -class vTcl
    wm transient .vTcl.varlist .vTcl
    wm focusmodel .vTcl.varlist passive
    wm geometry .vTcl.varlist 200x200+714+382
    wm maxsize .vTcl.varlist 1137 870
    wm minsize .vTcl.varlist 200 200
    wm overrideredirect .vTcl.varlist 0
    wm resizable .vTcl.varlist 1 1
    wm deiconify .vTcl.varlist
    wm title .vTcl.varlist "Variables"
    wm protocol $base WM_DELETE_WINDOW {vTcl:varlist:show 0}
    bind .vTcl.varlist <Double-Button-1> {
        set vTcl(x) [.vTcl.varlist.f2.list curselection]
        if {$vTcl(x) != ""} {
            vTcl:show_var [.vTcl.varlist.f2.list get $vTcl(x)]
        }
    }
    frame .vTcl.varlist.frame7 \
        -borderwidth 1 -height 30 -relief sunken -width 30 
    pack .vTcl.varlist.frame7 \
        -in .vTcl.varlist -anchor center -expand 0 -fill x -ipadx 0 -ipady 0 \
        -padx 0 -pady 0 -side bottom 
    button .vTcl.varlist.frame7.button8 \
        -command {vTcl:show_var ""} \
         -padx 9 \
        -pady 3 -text Add -width 4 
    pack .vTcl.varlist.frame7.button8 \
        -in .vTcl.varlist.frame7 -anchor center -expand 1 -fill x -ipadx 0 \
        -ipady 0 -padx 0 -pady 0 -side left 
    button .vTcl.varlist.frame7.button9 \
        -command {
            set vTcl(x) [.vTcl.varlist.f2.list curselection]
            if {$vTcl(x) != ""} {
                vTcl:show_var [.vTcl.varlist.f2.list get $vTcl(x)]
            }
        } \
         -padx 9 \
        -pady 3 -text Edit -width 4 
    pack .vTcl.varlist.frame7.button9 \
        -in .vTcl.varlist.frame7 -anchor center -expand 1 -fill x -ipadx 0 \
        -ipady 0 -padx 0 -pady 0 -side left 
    button .vTcl.varlist.frame7.button10 \
        -command {
            set vTcl(x) [.vTcl.varlist.f2.list curselection]
            if {$vTcl(x) != ""} {
                vTcl:delete_var [.vTcl.varlist.f2.list get $vTcl(x)]
                .vTcl.varlist.f2.list delete $vTcl(x)
            }
        } \
         -padx 9 \
        -pady 3 -text Delete -width 4 
    pack .vTcl.varlist.frame7.button10 \
        -in .vTcl.varlist.frame7 -anchor center -expand 1 -fill x -ipadx 0 \
        -ipady 0 -padx 0 -pady 0 -side left 
    button .vTcl.varlist.frame7.button11 \
        -command { vTcl:varlist:show 0 } \
        -padx 9 -pady 3 -text Done -width 4 
    pack .vTcl.varlist.frame7.button11 \
        -in .vTcl.varlist.frame7 -anchor center -expand 1 -fill x -ipadx 0 \
        -ipady 0 -padx 0 -pady 0 -side left 
    frame .vTcl.varlist.f2 \
        -borderwidth 1 -height 30 -relief sunken -width 30 
    pack .vTcl.varlist.f2 \
        -in .vTcl.varlist -anchor center -expand 1 -fill both -ipadx 0 \
        -ipady 0 -padx 0 -pady 0 -side top 
    listbox .vTcl.varlist.f2.list \
         \
        -yscrollcommand {.vTcl.varlist.f2.sb4  set} 
    pack .vTcl.varlist.f2.list \
        -in .vTcl.varlist.f2 -anchor center -expand 1 -fill both -ipadx 0 \
        -ipady 0 -padx 0 -pady 0 -side left 
    scrollbar .vTcl.varlist.f2.sb4 \
        -borderwidth 1 -command {.vTcl.varlist.f2.list yview}
    pack .vTcl.varlist.f2.sb4 \
        -in .vTcl.varlist.f2 -anchor center -expand 0 -fill y -ipadx 0 \
        -ipady 0 -padx 0 -pady 0 -side right 

    wm withdraw $vTcl(gui,varlist)
    vTcl:setup_vTcl:bind $vTcl(gui,varlist)
    catch {wm geometry $vTcl(gui,varlist) $vTcl(geometry,$vTcl(gui,varlist))}
    update idletasks
    wm deiconify $vTcl(gui,varlist)
}

