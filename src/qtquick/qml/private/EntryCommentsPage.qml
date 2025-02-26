/*
    SPDX-FileCopyrightText: 2019 Dan Leinir Turthra Jensen <admin@leinir.dk>

    SPDX-License-Identifier: LGPL-2.1-only OR LGPL-3.0-only OR LicenseRef-KDE-Accepted-LGPL
*/

/**
 * @brief A Kirigami.Page component used for displaying a NewStuff entry's comments
 */

import QtQuick 2.11
import QtQuick.Controls 2.11 as QtControls
import QtQuick.Layouts 1.11 as QtLayouts

import org.kde.kirigami 2.7 as Kirigami

import org.kde.newstuff 1.62 as NewStuff

Kirigami.ScrollablePage {
    id: component
    property string entryName
    property string entryAuthorId
    property string entryProviderId
    property alias entryIndex: commentsModel.entryIndex
    property alias itemsModel: commentsModel.itemsModel
    title: i18ndc("knewstuff6", "Title for the page containing a view of the comments for the entry", "Comments and Reviews for %1", component.entryName)
    actions: [
        Kirigami.Action {
            text: i18ndc("knewstuff6", "Title for the item which is checked when all comments should be shown", "Show All Comments")
            checked: commentsModel.includedComments == NewStuff.CommentsModel.IncludeAllComments
            checkable: true
            onTriggered: commentsModel.includedComments = NewStuff.CommentsModel.IncludeAllComments
        },
        Kirigami.Action {
            text: i18ndc("knewstuff6", "Title for the item which is checked when only comments which are reviews should be shown", "Show Reviews Only")
            checked: commentsModel.includedComments == NewStuff.CommentsModel.IncludeOnlyReviews
            checkable: true
            onTriggered: commentsModel.includedComments = NewStuff.CommentsModel.IncludeOnlyReviews
        },
        Kirigami.Action {
            text: i18ndc("knewstuff6", "Title for the item which is checked when comments which are reviews, and their children should be shown", "Show Reviews and Replies")
            checked: commentsModel.includedComments == NewStuff.CommentsModel.IncludeReviewsAndReplies
            checkable: true
            onTriggered: commentsModel.includedComments = NewStuff.CommentsModel.IncludeReviewsAndReplies
        }
    ]
    ErrorDisplayer { engine: component.itemsModel.engine; active: component.isCurrentPage; }
    ListView {
        id: commentsView
        model: NewStuff.CommentsModel {
            id: commentsModel
        }
        QtLayouts.Layout.fillWidth: true
        header: Item {
            anchors {
                left: parent.left
                right: parent.right
            }
            height: Kirigami.Units.largeSpacing
        }
        delegate: EntryCommentDelegate {
            engine: component.itemsModel.engine
            entryAuthorId: component.entryAuthorId
            entryProviderId: component.entryProviderId
            author: model.username
            score: model.score
            title: model.subject
            reviewText: model.text
            depth: model.depth
        }
    }
}
