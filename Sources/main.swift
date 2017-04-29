import Foundation
import CGLib
import CGtk
import GLib
import GLibObject
import Cairo
import Gdk
import Gtk

public extension Container {
    /// Set a child widget property
    ///
    /// - Parameters:
    ///   - child: widget to set property for
    ///   - property: `ParamSpec` for property
    ///   - value: value to set
    /// - Returns: `true` if successful, `false` if value cannot be transformed
    @discardableResult
    public func set<W: WidgetProtocol, P: ParamSpecProtocol, V: ValueProtocol>(child: W, property: P, value: V) -> Bool {
        let container = ptr.withMemoryRebound(to: GtkContainer.self, capacity: 1) { $0 }
        let ptype = property.ptr.pointee.value_type
        let tmpValue = Value()
        _ = tmpValue.init_(gType: ptype)
        defer { tmpValue.unset() }
        guard value.transform(destValue: tmpValue) /* &&
              (property.paramValueValidate(value: tmpValue) ||
               (property.ptr.pointee.flags.rawValue & (ParamFlags.lax_validation)) != 0) */ else { return false }
        let paramID = property.ptr.pointee.param_id
        let widget = child.ptr.withMemoryRebound(to: GtkWidget.self, capacity: 1) { $0 }
        let typeClass = ContainerClassRef(raw: typeClassPeek(type: ptype))
        typeClass.ptr.pointee.set_child_property(container, widget, paramID, tmpValue.ptr, property.ptr)
        return true
    }
    public func set<W: WidgetProtocol, P: PropertyNameProtocol, V>(child widget: W, property: P, value: V) {
        guard let paramSpec = ParamSpecRef(name: property, from:_gtk_widget_child_property_pool) else {
            g_warning("\(#file): container class \(typeName) has no child property named \(property.rawValue)")
            return
        }
        let v = Value(value)
        set(child: widget, property: paramSpec, value: v)
    }
    /// Set the property of a child widget
    ///
    /// - Parameters:
    ///   - child: widget to set property for
    ///   - property: name of the property
    ///   - value: value to set
    public func set<W: WidgetProtocol, P: PropertyNameProtocol>(child widget: W, properties: [(P, Any)]) {
        let nq = widget.freeze(context: _gtk_widget_child_property_notify_context)
        defer { if let nq = nq { widget.thaw(queue: nq) } }
        for (p, v) in properties {
            set(child: widget, property: p, value: v)
        }
    }
    /// Set up a child widget with the given list of properties
    ///
    /// - Parameters:
    ///   - widget: child widget to set properties for
    ///   - properties: `PropertyName` / value pairs to set
    public func set<W: WidgetProtocol, P: PropertyNameProtocol>(child widget: W, properties ps: (P, Any)...) {
        set(child: widget, properties: ps)
    }
    /// Add a child widget with a given list of properties
    ///
    /// - Parameters:
    ///   - widget: child widget to add
    ///   - properties: `PropertyName` / value pairs of properties to set
    public func add<W: WidgetProtocol, P: PropertyNameProtocol>(_ widget: W, properties ps: (P, Any)...) {
        widget.freezeChildNotify() ; defer { widget.thawChildNotify() }
        emit(ContainerSignalName.add, widget.ptr)
        set(child: widget, properties: ps)
    }
    /// Add a child widget with a given property
    ///
    /// - Parameters:
    ///   - widget: child widget to add
    ///   - property: name of the property to set
    ///   - value: value of the property to set
    public func add<W: WidgetProtocol, P: PropertyNameProtocol, V>(_ widget: W, property p: P, value v: V) {
        widget.freezeChildNotify() ; defer { widget.thawChildNotify() }
        emit(ContainerSignalName.add, widget.ptr)
        set(child: widget, property: p, value: v)
    }
}

public extension WidgetProtocol {
    /// Set a drag source
    ///
    /// - Parameters:
    ///   - startButton: button to start dragging from (defaults to `.button1_mask`)
    ///   - action: drag action to perform (defaults to `.copy`)
    ///   - targets: array of targets to target
    public func dragSourceSet(startButton: Gdk.ModifierType = .button1_mask, action: Gdk.DragAction = .copy, targets: [String]) {
        var t = targets.map { GtkTargetEntry(target: $0) }
        dragSourceSet(startButtonMask: startButton, targets: &t, nTargets: CInt(t.count), actions: action)
    }
    /// Set a drag source
    ///
    /// - Parameters:
    ///   - startButton: button to start dragging from (defaults to `.button1_mask`)
    ///   - action: drag action to perform (defaults to `.copy`)
    ///   - targets: array of targets to target
    public func dragSourceSet(startButton: Gdk.ModifierType = .button1_mask, action: Gdk.DragAction = .copy, targets: [GtkTargetEntry]) {
        var t = targets
        dragSourceSet(startButtonMask: startButton, targets: &t, nTargets: CInt(t.count), actions: action)
    }
    /// Set a drag source
    ///
    /// - Parameters:
    ///   - startButton: button to start dragging from (defaults to `.button1_mask`)
    ///   - action: drag action to perform (defaults to `.copy`)
    ///   - targets: list of targets to target
    public func dragSourceSet(startButton b: Gdk.ModifierType = .button1_mask, action a: Gdk.DragAction = .copy, targets t: String...) {
        dragSourceSet(startButton: b, action: a, targets: t)
    }
    /// Set a drag source
    ///
    /// - Parameters:
    ///   - startButton: button to start dragging from (defaults to `.button1_mask`)
    ///   - action: drag action to perform (defaults to `.copy`)
    ///   - targets: list of targets to target
    public func dragSourceSet(startButton b: Gdk.ModifierType = .button1_mask, action a: Gdk.DragAction = .copy, targets t: GtkTargetEntry...) {
        dragSourceSet(startButton: b, action: a, targets: t)
    }

    /// Set a drag destination
    ///
    /// - Parameters:
    ///   - flags: destination defaults (defaults to `.all`)
    ///   - action: drag action to perform (defaults to `.copy`)
    ///   - targets: array of targets to target
    public func dragDestSet(flags f: DestDefaults = .all, action a: Gdk.DragAction = .copy, targets: [String]) {
        var t = targets.map { GtkTargetEntry(target: $0) }
        dragDestSet(flags: f, targets: &t, nTargets: CInt(t.count), actions: a)
    }
    /// Set a drag destination
    ///
    /// - Parameters:
    ///   - flags: destination defaults (defaults to `.all`)
    ///   - action: drag action to perform (defaults to `.copy`)
    ///   - targets: array of targets to target
    public func dragDestSet(flags f: DestDefaults = .all, action a: Gdk.DragAction = .copy, targets: [GtkTargetEntry]) {
        var t = targets
        dragDestSet(flags: f, targets: &t, nTargets: CInt(t.count), actions: a)
    }
    /// Set a drag destination
    ///
    /// - Parameters:
    ///   - flags: destination defaults (defaults to `.all`)
    ///   - action: drag action to perform (defaults to `.copy`)
    ///   - targets: list of targets to target
    public func dragDestSet(flags f: DestDefaults = .all, action a: Gdk.DragAction = .copy, targets t: String...) {
        dragDestSet(flags: f, action: a, targets: t)
    }
    /// Set a drag destination
    ///
    /// - Parameters:
    ///   - flags: destination defaults (defaults to `.all`)
    ///   - action: drag action to perform (defaults to `.copy`)
    ///   - targets: list of targets to target
    public func dragDestSet(flags f: DestDefaults = .all, action a: Gdk.DragAction = .copy, targets t: GtkTargetEntry...) {
        dragDestSet(flags: f, action: a, targets: t)
    }
}


public extension BoxProtocol {
    /// Set the start margin of the box
    ///
    /// - Parameter marginStart: start margin
    public func set(marginStart: Int) { setMarginStart(margin: CInt(marginStart)) }
    /// Set the end margin of the box
    ///
    /// - Parameter marginEnd: end margin
    public func set(marginEnd: Int) { setMarginStart(margin: CInt(marginEnd)) }
}

public extension Box {
    /// Set the property of a child widget of this box
    ///
    /// - Parameters:
    ///   - child: widget to set property for
    ///   - property: name of the property
    ///   - value: value to set
    public func set<W: WidgetProtocol>(child widget: W, properties: [(BoxPropertyName, Any)]) {
        let nq = widget.freeze(context: _gtk_widget_child_property_notify_context)
        defer { if let nq = nq { widget.thaw(queue: nq) } }
        for (p, v) in properties {
            set(child: widget, property: p, value: v)
        }
    }
    /// Set up a child widget of this box with the given list of properties
    ///
    /// - Parameters:
    ///   - widget: child widget to set properties for
    ///   - properties: `PropertyName` / value pairs to set
    public func set<W: WidgetProtocol>(child widget: W, properties ps: (BoxPropertyName, Any)...) {
        set(child: widget, properties: ps)
    }
    /// Add a child widget to this box with a given list of properties
    ///
    /// - Parameters:
    ///   - widget: child widget to add
    ///   - properties: `PropertyName` / value pairs of properties to set
    public func add<W: WidgetProtocol>(_ widget: W, properties ps: (BoxPropertyName, Any)...) {
        widget.freezeChildNotify() ; defer { widget.thawChildNotify() }
        emit(ContainerSignalName.add, widget.ptr)
        set(child: widget, properties: ps)
    }
    /// Add a child widget to this box with a given property
    ///
    /// - Parameters:
    ///   - widget: child widget to add
    ///   - property: name of the property to set
    ///   - value: value of the property to set
    public func add<W: WidgetProtocol, V>(_ widget: W, property p: BoxPropertyName, value v: V) {
        widget.freezeChildNotify() ; defer { widget.thawChildNotify() }
        emit(ContainerSignalName.add, widget.ptr)
        set(child: widget, property: p, value: v)
    }
}

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
            let s = imageSurfaceCreate(format: CAIRO_FORMAT_ARGB32, width: w, height: h)
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
        hdl.onDragDataReceived { (widget, context, x, y, selectionData, info, time) in
            let target = ListBoxRowRef(cPointer: widget.ptr)
            let pos = target.index
            let row = WidgetRef(gtk_selection_data_get_data(selectionData).withMemoryRebound(to: UnsafeMutablePointer<GtkWidget>.self, capacity: 1, { $0 }).pointee)
            let source = ListBoxRowRef(cPointer: row.getAncestor(widgetType: gtk_list_box_row_get_type()))

            guard source.ptr != target.ptr else { return }

            _ = source.ref()
            let parent = ContainerRef(cPointer: source.parent)
            parent.remove(widget: source)
            let listBox = ListBoxRef(cPointer: target.parent)
            listBox.insert(child: source, position: pos)
            source.unref()
        }
        return row
    }
}
var entries = [GtkTargetEntry(target: "GTK_LIST_BOX_ROW")]

gtk_init(nil, nil)

guard let screen = ScreenRef.getDefault() else { exit(EXIT_FAILURE) }

let css = try! CSSProvider(from: ".drag-icon { "
    + "  background: white; "
    + "  border: 1px solid black; "
    + "}")
screen.add(provider: css, priority: STYLE_PROVIDER_PRIORITY_APPLICATION)

let window = Window(type: .toplevel)
window.setDefaultSize(width: 200, height: 320)

var sw = ScrolledWindow()
sw.hexpand = true
sw.setPolicy(hscrollbarPolicy: .never, vscrollbarPolicy: .always)
window.add(widget: sw)

var list = ListBox()
list.selectionMode = .none_
sw.add(widget: list)

for i: CInt in 0..<20 {
    let row = ListBoxRow.row("Row \(i)")
    list.insert(child: row, position: i)
}

window.showAll()

gtk_main()
