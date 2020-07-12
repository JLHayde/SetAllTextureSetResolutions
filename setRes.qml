import QtQuick 2.3
import QtQuick.Layouts 1.2
import QtQuick.Dialogs 1.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import AlgWidgets 2.0
import AlgWidgets.Style 2.0


AlgToolBarButton {
  id: control
  tooltip: "Set Udim Resolutions"
  iconName: control.hovered && !control.loading ? "icons/SetAllRes_hovered.svg" : "icons/SetAllRes_idle.svg"

  QtObject {
    id: internal
    function launchSetResDialog() {
      exportDialog.open()
    }
  }
  ExportDialog {
      id: exportDialog

      onAccepted: {
      }
  }

  onClicked: {
        internal.launchSetResDialog()
      }
}
