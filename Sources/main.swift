import Foundation
import CGtk
import Gdk
import Gtk

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
