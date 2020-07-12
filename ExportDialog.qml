import QtQuick 2.3
import QtQuick.Window 2.2
import QtQuick.Dialogs 1.2
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3
import AlgWidgets 2.0
  


AlgDialog {
    id: window
    width: 400
    height: 300
    minimumWidth: 400
    minimumHeight: 300
    defaultButtonText: "Set resolution"
    title: "Choose Texture Sets/UDIM's"

    property int ddValue: 7 

    QtObject {
        id: internal
        property var documentType: {
            'Material': "material",
        }

        function nextModelIndex(model, materialName) {
            var result = 0
            for (result = 0; result < model.count; ++result) {
                var modelObject = model.get(result)
                if (modelObject.type === documentType.Material && modelObject.name.localeCompare(materialName) > 0) {
                    break
                }
            }
            return result
        }
    }

    function reload() {
        var documentStructure = alg.mapexport.documentStructure()
        documentStructureModel.clear()
        for (var materialId in documentStructure.materials) {
            var material = documentStructure.materials[materialId]
            var id = internal.nextModelIndex(documentStructureModel, material.name)
            var modelMaterialId = id
            var matDescription = alg.texturesets.structure(material.name)
            documentStructureModel.insert(id,
                                          {'name': material.name,
                                           'path': material.name,
                                           'type': internal.documentType.Material,
                                           'description': matDescription["description"],
                                           'parentIndex': 0})
      }
    }
    // Here we get all check boxes and Material/UDIM names for the setResolution Function
    onAccepted: {
        for (var i = 0; i < repeater.count; ++i) {
            if (repeater.itemAt(i).checked){
                alg.texturesets.setResolution(repeater.itemAt(i).theMatName,[ddValue,ddValue])
            }
        }
    }

    ListModel {
        id: documentStructureModel
    }

    Rectangle {
        id: content
        parent: contentItem
        anchors.fill: parent
        anchors.margins: 12
        color: "transparent"
        clip: true

        ColumnLayout {
            spacing: 6
            anchors.fill: parent

            Flow {
                id: controlButtons
                spacing: 6
                layoutDirection: Qt.RightToLeft

                AlgComboBox {
                    id: resDropDown
                    model:  [{ text:"128x128", value:7},
                            { text:"256x256", value:8},
                            { text: "512x512", value:9},
                            { text: "1024x1024", value:10},
                            { text: "2048x2048", value:11},
                            { text: "4096x4096", value:12}]
                    textRole: "text"
                    onActivated: {
                        ddValue = (model[index].value);
                        }
                        
                    }
                AlgLabel {
                text: " Size"
                }
                AlgButton {
                    id: noneButton
                    text: " None"
                }
                AlgButton {
                    id: allButton
                    text: " All"
                }
            }

            AlgScrollView {
                id: scrollView
                Layout.fillWidth: true
                Layout.fillHeight: true

                ColumnLayout {
                    spacing: 6
                    Layout.minimumWidth: scrollView.viewportWidth
                    Layout.maximumWidth: scrollView.viewportWidth

                    Repeater {
                        id: repeater
                        model: documentStructureModel
                        RowLayout {
                            id: rowItem
                            spacing: 6
                            property int paddingSize: type === internal.documentType.Stack ?
                                                          10 : type === internal.documentType.Channel ?
                                                              20 : 0
                            property var prevItem: null
                            property alias checked: modelCheckBox.checked
                            property string documentPath: model.path
                            property string theMatName: model.path
                            signal clicked()
                            Layout.leftMargin: paddingSize
                            Layout.minimumWidth: scrollView.viewportWidth - paddingSize
                            Layout.maximumWidth: scrollView.viewportWidth - paddingSize

                            Component.onCompleted: {
                                if (parentIndex > 0) prevItem = repeater.itemAt(index - parentIndex)
                            }

                            AlgCheckBox {
                                id: modelCheckBox
                                //checked: defaultChecked
                                Layout.preferredWidth: height


                                onClicked: {
                                    rowItem.clicked()
                                }

                                onCheckedChanged: {
                                    if (prevItem && checked) {
                                        prevItem.checked = true;
                                    }
                                }

                                Connections {
                                    target: noneButton
                                    onClicked: {
                                       checked = false
                                    }
                                }
                                Connections {
                                    target: allButton
                                    onClicked: {
                                       checked = true
                                    }
                                }
                                Connections {
                                    target: prevItem
                                    onClicked: {
                                        checked = prevItem.checked
                                        // transmit event to children
                                        rowItem.clicked()
                                    }
                                }
                            }
                            AlgTextEdit {
                                readOnly: true
                                borderActivated: true
                                borderOpacity: 0.3
                                Layout.fillWidth: true
                                text: name + ": " + description
                            }
                        }
                    }
                }
            }
        }
    }
}
