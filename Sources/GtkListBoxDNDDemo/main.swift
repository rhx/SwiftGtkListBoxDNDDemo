import Foundation
import CGtk
import Gdk
import Gtk

gtk_init(nil, nil)

guard let screen = ScreenRef.getDefault() else { exit(EXIT_FAILURE) }

let css = try! CSSProvider(from: ".drag-icon { "
    + "  background: white; "
    + "  border: 1px solid black; "
    + "}\n\n"
    + ".drag-hover-top {"
    + "  background: linear-gradient(to bottom, rgba(0,0,0,0.65) 0%,rgba(0,0,0,0) 35%); "
    + "}\n\n"
    + ".drag-hover-bottom {"
    + "  background: linear-gradient(to bottom, rgba(0,0,0,0) 65%,rgba(0,0,0,0.65) 100%); "
    + "}"
)
screen.add(provider: css, priority: STYLE_PROVIDER_PRIORITY_APPLICATION)

let window = Window(type: .toplevel)
window.setDefaultSize(width: 200, height: 320)

var sw = ScrolledWindow()
sw.hexpand = true
sw.setPolicy(hscrollbarPolicy: .never, vscrollbarPolicy: .always)
window.add(widget: sw)

var list = ListBox()
list.selectionMode = .none
sw.add(widget: list)

for i in 0..<20 {
    let row = ListBoxRow.row("Row \(i)")
    list.insert(child: row, position: i)
}


//list.dragMotion(context: <#T##DragContextProtocol#>, destWindow: <#T##WindowProtocol#>, protocol_: <#T##Drag_Protocol#>, xRoot: <#T##CInt#>, yRoot: <#T##CInt#>, suggestedAction: <#T##DragAction#>, possibleActions: <#T##DragAction#>, time_: <#T##UInt32#>)
window.showAll()

gtk_main()
