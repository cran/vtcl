##############################################################################
# $Id: tops.tcl,v 1.9 1997/04/23 05:45:20 stewart Exp $
#
# tops.tcl - procedures for managing toplevel windows
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

proc vTcl:wm_take_focus {target} {
    global vTcl
    if {$vTcl(w,class) == "Toplevel"} {
        set vTcl(w,insert) $target
    }
    vTcl:place_handles $vTcl(w,widget)
}

proc vTcl:destroy_top {target} {
    global vTcl
    if [winfo exists $target] {
        if {[vTcl:get_class $target] == "Toplevel"} {
            destroy $target
        }
    }
    if {[info procs vTclWindow$target] != ""} {
        rename vTclWindow$target {}
    }
    if {[info procs vTclWindow(pre)$target] != ""} {
        rename vTclWindow$target {}
    }
    if {[info procs vTclWindow(post)$target] != ""} {
        rename vTclWindow$target {}
    }
    set x [lsearch $vTcl(tops) $target]
    if {$x >= 0} {
        set vTcl(tops) [lreplace $vTcl(tops) $x $x]
    }
}

proc vTcl:show_top {target} {
    global vTcl
    if [winfo exists $target] {
        if {[vTcl:get_class $target] == "Toplevel"} {
            wm deiconify $target
            raise $target
        }
    } else {
        Window show $target
        wm deiconify $target
        raise $target
        vTcl:setup_bind_tree $target
        vTcl:update_top_list
    }
}

proc vTcl:hide_top {target} {
    global vTcl
    if [winfo exists $target] {
        if {[vTcl:get_class $target] == "Toplevel"} {
            wm withdraw $target
        }
    }
}

proc vTcl:update_top_list {} {
    global vTcl
    if [winfo exists .vTcl.toplist] {
        .vTcl.toplist.f2.list delete 0 end
        set index 0
        foreach i $vTcl(tops) {
            if [catch {set n [wm title $i]}] {
                set n $i
            }
            .vTcl.toplist.f2.list insert end $n
            set vTcl(tops,$index) $i
            incr index
        }
    }
}

proc vTcl:toplist:show {{on ""}} {
    global vTcl
    if {$on == "flip"} { set on [expr - $vTcl(pr,show_top)] }
    if {$on == ""}     { set on $vTcl(pr,show_top) }
    if {$on == 1} {
        Window show $vTcl(gui,toplist)
        vTcl:update_top_list
    } else {
        Window hide $vTcl(gui,toplist)
    }
    set vTcl(pr,show_top) $on
}

proc vTclWindow.vTcl.toplist {args} {
    global vTcl
    set base .vTcl.toplist
    if {[winfo exists .vTcl.toplist]} {
        wm deiconify .vTcl.toplist; return
    }
    toplevel .vTcl.toplist -class vTcl
    wm focusmodel .vTcl.toplist passive
    wm geometry .vTcl.toplist 200x200+714+382
    wm maxsize .vTcl.toplist 1137 870
    wm minsize .vTcl.toplist 200 200
    wm overrideredirect .vTcl.toplist 0
    wm resizable .vTcl.toplist 1 1
    wm deiconify .vTcl.toplist
    wm title .vTcl.toplist "Toplevel Windows"
    wm protocol $base WM_DELETE_WINDOW {vTcl:toplist:show 0}
    bind .vTcl.toplist <Double-Button-1> {
        set vTcl(x) [.vTcl.toplist.f2.list curselection]
        if {$vTcl(x) != ""} {
            vTcl:show_top $vTcl(tops,$vTcl(x))
        }
    }
    frame .vTcl.toplist.frame7 \
        -borderwidth 1 -height 30 -relief sunken -width 30 
    pack .vTcl.toplist.frame7 \
        -in .vTcl.toplist -anchor center -expand 0 -fill x -ipadx 0 -ipady 0 \
        -padx 0 -pady 0 -side bottom 
    button .vTcl.toplist.frame7.button8 \
        -command {
            set vTcl(x) [.vTcl.toplist.f2.list curselection]
            if {$vTcl(x) != ""} {
                vTcl:show_top $vTcl(tops,$vTcl(x))
            }
        } \
         -padx 9 \
        -pady 3 -text Show -width 4 
    pack .vTcl.toplist.frame7.button8 \
        -in .vTcl.toplist.frame7 -anchor center -expand 1 -fill x -ipadx 0 \
        -ipady 0 -padx 0 -pady 0 -side left 
    button .vTcl.toplist.frame7.button9 \
        -command {
            set vTcl(x) [.vTcl.toplist.f2.list curselection]
            if {$vTcl(x) != ""} {
                vTcl:hide_top $vTcl(tops,$vTcl(x))
            }
        } \
         -padx 9 \
        -pady 3 -text Hide -width 4 
    pack .vTcl.toplist.frame7.button9 \
        -in .vTcl.toplist.frame7 -anchor center -expand 1 -fill x -ipadx 0 \
        -ipady 0 -padx 0 -pady 0 -side left 
    button .vTcl.toplist.frame7.button10 \
        -command {
            set vTcl(x) [.vTcl.toplist.f2.list curselection]
            if {$vTcl(x) != ""} {
                vTcl:destroy_top $vTcl(tops,$vTcl(x))
                .vTcl.toplist.f2.list delete $vTcl(x)
            }
        } \
         -padx 9 \
        -pady 3 -text Delete -width 4
    pack .vTcl.toplist.frame7.button10 \
        -in .vTcl.toplist.frame7 -anchor center -expand 1 -fill x -ipadx 0 \
        -ipady 0 -padx 0 -pady 0 -side left 
    button .vTcl.toplist.frame7.button11 \
        -command { vTcl:toplist:show 0 } \
         -padx 9 \
        -pady 3 -text Done -width 4 
    pack .vTcl.toplist.frame7.button11 \
        -in .vTcl.toplist.frame7 -anchor center -expand 1 -fill x -ipadx 0 \
        -ipady 0 -padx 0 -pady 0 -side left 
    frame .vTcl.toplist.f2 \
        -borderwidth 1 -height 30 -relief sunken -width 30 
    pack .vTcl.toplist.f2 \
        -in .vTcl.toplist -anchor center -expand 1 -fill both -ipadx 0 \
        -ipady 0 -padx 0 -pady 0 -side top 
    listbox .vTcl.toplist.f2.list \
        -yscrollcommand {.vTcl.toplist.f2.sb4 set} -exportselection 0
    pack .vTcl.toplist.f2.list \
        -in .vTcl.toplist.f2 -anchor center -expand 1 -fill both -ipadx 0 \
        -ipady 0 -padx 0 -pady 0 -side left 
    scrollbar .vTcl.toplist.f2.sb4 \
        -command {.vTcl.toplist.f2.list yview}
    pack .vTcl.toplist.f2.sb4 \
        -in .vTcl.toplist.f2 -anchor center -expand 0 -fill y -ipadx 0 \
        -ipady 0 -padx 0 -pady 0 -side right 

    wm withdraw .vTcl.toplist
    vTcl:setup_vTcl:bind .vTcl.toplist
    catch {wm geometry .vTcl.toplist $vTcl(geometry,.vTcl.toplist)}
    update idletasks
    wm deiconify .vTcl.toplist
}

