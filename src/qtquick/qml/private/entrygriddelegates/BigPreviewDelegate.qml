/*
 * Copyright (C) 2019 Dan Leinir Turthra Jensen <admin@leinir.dk>
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) version 3, or any
 * later version accepted by the membership of KDE e.V. (or its
 * successor approved by the membership of KDE e.V.), which shall
 * act as a proxy defined in Section 6 of version 3 of the license.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

import QtQuick 2.11
import QtQuick.Controls 2.11 as QtControls
import QtQuick.Layouts 1.11 as QtLayouts
import QtGraphicalEffects 1.11 as QtEffects

import org.kde.kirigami 2.7 as Kirigami

import org.kde.newstuff 1.62 as NewStuff

import ".." as Private

Private.GridTileDelegate {
    id: component
    actionsAnchors.topMargin: bigPreview.height + Kirigami.Units.smallSpacing * 2
    function showDetails() {
        pageStack.push(detailsPage, {
            newStuffModel: GridView.view.model,
            index: model.index,
            name: model.name,
            author: model.author,
            previews: model.previews,
            shortSummary: model.shortSummary,
            summary: model.summary,
            homepage: model.homepage,
            donationLink: model.donationLink,
            status: model.status,
            commentsCount: model.numberOfComments,
            rating: model.rating,
            downloadCount: model.downloadCount,
            downloadLinks: model.downloadLinks,
            providerId: model.providerId
        });
    }
    actions: [
        Kirigami.Action {
            text: root.useLabel
            iconName: "dialog-ok-apply"
            onTriggered: { model.adopt(model.index); }
            enabled: (model.status == NewStuff.ItemsModel.InstalledStatus || model.status == NewStuff.ItemsModel.UpdateableStatus) && newStuffEngine.hasAdoptionCommand
            visible: enabled
        },
        Kirigami.Action {
            text: model.downloadLinks.length === 1 ? i18nc("Request installation of this item, available when there is exactly one downloadable item", "Install") : i18nc("Show installation options, where there is more than one downloadable item", "Install...");
            iconName: "install"
            onTriggered: {
                if (model.downloadLinks.length === 1) {
                    newStuffModel.installItem(model.index, 1);
                } else {
                    downloadItemsSheet.downloadLinks = model.downloadLinks;
                    downloadItemsSheet.entryId = model.index;
                    downloadItemsSheet.open();
                }
            }
            enabled: model.status == NewStuff.ItemsModel.DownloadableStatus || model.status == NewStuff.ItemsModel.DeletedStatus;
            visible: enabled;
        },
        Kirigami.Action {
            text: i18nc("Request updating of this item", "Update");
            iconName: "update"
            onTriggered: { newStuffModel.installItem(model.index); }
            enabled: model.status == NewStuff.ItemsModel.UpdateableStatus;
            visible: enabled;
        },
        Kirigami.Action {
            text: root.uninstallLabel
            iconName: "uninstall"
            onTriggered: { newStuffModel.uninstallItem(model.index); }
            enabled: model.status == NewStuff.ItemsModel.InstalledStatus
            visible: enabled;
        }
    ]
    thumbnailAvailable: model.previewsSmall.length > 0
    tile: Item {
        anchors {
            fill: parent
            margins: Kirigami.Units.smallSpacing
        }
        QtLayouts.ColumnLayout {
            anchors.fill: parent;
            Item {
                QtLayouts.Layout.fillWidth: true
                QtLayouts.Layout.minimumHeight: width / 1.8
                QtLayouts.Layout.maximumHeight: width / 1.8
                Image {
                    id: bigPreview
                    asynchronous: true;
                    fillMode: Image.PreserveAspectCrop;
                    source: thumbnailAvailable ? model.previews[0] : "";
                    anchors.fill: parent
                }
                QtEffects.DropShadow {
                    anchors.fill: bigPreview
                    horizontalOffset: 0
                    verticalOffset: 0
                    radius: Kirigami.Units.largeSpacing
                    samples: radius * 2
                    color: "#80000000"
                    source: bigPreview
                }
                Kirigami.Icon {
                    id: updateAvailableBadge;
                    opacity: (model.status == NewStuff.ItemsModel.UpdateableStatus) ? 1 : 0;
                    Behavior on opacity { NumberAnimation { duration: Kirigami.Units.shortDuration; } }
                    anchors {
                        top: parent.top;
                        left: parent.left;
                        margins: -Kirigami.Units.smallSpacing;
                    }
                    height: Kirigami.Units.iconSizes.medium;
                    width: height;
                    source: "package-installed-outdated";
                }
                Kirigami.Icon {
                    id: installedBadge;
                    opacity: (model.status == NewStuff.ItemsModel.InstalledStatus) ? 1 : 0;
                    Behavior on opacity { NumberAnimation { duration: Kirigami.Units.shortDuration; } }
                    anchors {
                        top: parent.top;
                        left: parent.left;
                    }
                    height: Kirigami.Units.iconSizes.medium;
                    width: height;
                    source: "package-installed-updated";
                }
                Item {
                    anchors {
                        top: parent.top;
                        right: parent.right;
                    }
                    height: Kirigami.Units.iconSizes.large;
                    width: height;
                    Kirigami.Icon {
                        id: infoIcon
                        source: "documentinfo"
                        anchors.fill: parent
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: { component.showDetails(); }
                    }
                    QtEffects.Glow {
                        anchors.fill: infoIcon
                        radius: 1
                        samples: 2
                        spread: 0.3
                        color: "white"
                        source: infoIcon
                    }
                }
            }
            Private.Rating {
                QtLayouts.Layout.fillWidth: true
                rating: model.rating / 10
            }
            Kirigami.Heading {
                QtLayouts.Layout.fillWidth: true
                level: 5
                elide: Text.ElideRight
                text: i18nc("The number of times the item has been downloaded", "%1 downloads").arg(model.downloadCount)
            }
            Kirigami.Heading {
                QtLayouts.Layout.fillWidth: true
                elide: Text.ElideRight
                level: 3
                text: model.name
            }
            Kirigami.Heading {
                QtLayouts.Layout.fillWidth: true
                elide: Text.ElideRight
                level: 4
                textFormat: Text.StyledText
                text: i18nc("Subheading for the tile view, located immediately underneath the name of the item", "By <i>%1</i>").arg(model.author.name)
            }
            QtControls.Label {
                QtLayouts.Layout.fillWidth: true
                QtLayouts.Layout.fillHeight: true
                wrapMode: Text.Wrap
                text: model.shortSummary.length > 0 ? model.shortSummary : model.summary
                elide: Text.ElideRight
            }
        }
        FeedbackOverlay {
            anchors.fill: parent
            newStuffModel: component.GridView.view.model
        }
        MouseArea {
            anchors.fill: parent;
            cursorShape: Qt.PointingHandCursor;
            onClicked: component.showDetails();
        }
    }
}
