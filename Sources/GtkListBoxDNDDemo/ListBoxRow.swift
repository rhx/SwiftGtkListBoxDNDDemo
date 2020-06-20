//
//  ListBoxRow.swift
//  GtkListBoxDNDDemo
//
//  Created by Rene Hexel on 29/4/17.
//
import CGLib
import CGtk
import CCairo
import Cairo
import Gdk
import Gtk

extension ListBoxRow {
    static func row(_ content: String) -> ListBoxRow {
        let row = ListBoxRow()
        let box = Box(orientation: .horizontal, spacing: 10)
        box.set(marginStart: 10)
        box.set(marginEnd: 10)
        row.add(widget: box)

        let hdl = EventBox()
        let img = Image(iconName: "open-menu-symbolic", size: .menu)
        hdl.add(widget: img)
        box.add(widget: hdl)

        let label = Label(str: content)
        box.add(label, property: .expand, value: true)

        hdl.dragSourceSet(action: .move, targets: entries)
        hdl.onDragBegin {
            let context = $1
            let w = Int(row.allocatedWidth)
            let h = Int(row.allocatedHeight)
            let argb32 = CCairo.cairo_format_t.argb32
            let s = imageSurfaceCreate(format: argb32, width: w, height: h)
            let cr = Context(surface: s)
            let styleContext = row.styleContextRef
            let dragIcon = "drag-icon"
            styleContext.addClass(className: dragIcon)
            row.draw(cr: cr)
            styleContext.removeClass(className: dragIcon)

            var x = CInt(0)
            var y = CInt(0)
            _ = hdl.translateCoordinates(destWidget: row, srcX: 0, srcY: 0, destX: &x, destY: &y)
            s.setDeviceOffset(x: Double(-x), y: Double(-y))
            context.set(icon: s)
        }
        hdl.onDragDataGet { (widget, context, selectionData, info, time) in
            var w = widget.ptr
            withUnsafePointer(to: &w) {
                $0.withMemoryRebound(to: guchar.self, capacity: 1) {
                    gtk_selection_data_set(selectionData, gdk_atom_intern_static_string("GTK_LIST_BOX_ROW"), 32, $0, gint(MemoryLayout<gpointer>.size))
                }
            }
        }
        row.dragDestSet(flags: .all, action: .move, targets: entries)
        row.onDragDataReceived { (widget, context, x, y, selectionData, info, time) in
            let target = ListBoxRowRef(cPointer: widget.widget_ptr)
            let pos = target.index
            let row = WidgetRef(gtk_selection_data_get_data(selectionData).withMemoryRebound(to: UnsafeMutablePointer<GtkWidget>.self, capacity: 1, { $0 }).pointee)
            let source = ListBoxRowRef(cPointer: row.getAncestor(widgetType: gtk_list_box_row_get_type()))

            guard source.ptr != target.ptr else { return }

            _ = source.ref()
            let parent = ContainerRef(cPointer: source.parent)
            parent.remove(widget: source)
            let listBox = ListBoxRef(cPointer: target.parent)
            listBox.insert(child: source, position: CInt(pos))
            source.unref()
        }
        return row
    }
}

var entries = GtkTargetEntries("GTK_LIST_BOX_ROW")
