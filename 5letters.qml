import QtQuick
import QtQuick.Controls

Window
{
    width: 250
    height: 250
    visible: true
    title: "5 letters"
    color: "#000000"

    Engine
    {
        id: engine

        word: "glory"
        property int tryCount: 0
        property int maxTryCount: 5
    }

    TextInput
    {
        id: input

        anchors.fill: parent

        visible: false
        focus: true

        validator: RegularExpressionValidator { regularExpression: /[a-z]{5}/ }

        onAccepted:
        {
            function isWin(letterStates)
            {
                for (const letterState of letterStates)
                {
                    if (letterState !== Engine.LetterState.CorrectSymbolAndPosition)
                    {
                        return false
                    }
                }

                return true
            }

            const letterStates = engine.validate(input.text)

            table.setLetterStates(letterStates)

            input.text = ""
            ++engine.tryCount

            if (isWin(letterStates))
            {
                input.focus = false

                messageBox.text = "You win!"
                messageBox.visible = true
            }
            else
            {
                if (engine.tryCount == engine.maxTryCount)
                {
                    input.focus = false

                    messageBox.text = "You lose!"
                    messageBox.visible = true
                }
            }
        }

        onTextEdited:
        {
            table.onTextEdited(text)
        }
    }

    Item
    {
        id: table

        property int rowIndex: engine.tryCount
        property int rowCount: engine.maxTryCount
        property int columnCount: engine.word.length

        property int diagonal: Math.round(Math.sqrt(width*width + height*height))

        function onTextEdited(text)
        {
            row.itemAt(rowIndex).clear()
            row.itemAt(rowIndex).onTextEdited(text)
        }

        function setLetterStates(letterStates)
        {
            row.itemAt(rowIndex).setLetterStates(letterStates)
        }

        anchors.fill: parent

        Column
        {
            id: columns

            spacing: 0.01 * table.diagonal
            padding: 5 * spacing

            Repeater
            {
                id: row
                model: table.rowCount

                Row
                {
                    id: rows

                    spacing: parent.spacing

                    // Print text in current row
                    function onTextEdited(text)
                    {
                        for (var i = 0; i < column.model && i < text.length; ++i)
                        {
                            column.itemAt(i).text = text[i]
                        }
                    }

                    // Clear a word in crrent row
                    function clear()
                    {
                        for (var i = 0; i < column.model; ++i)
                        {
                            column.itemAt(i).text = ""
                        }
                    }

                    function setLetterStates(letterStates)
                    {
                        for (var i = 0; i < column.model; ++i)
                        {
                            column.itemAt(i).letterState = letterStates[i]
                        }
                    }

                    Repeater
                    {
                        id: column
                        model: table.columnCount

                        Rectangle
                        {
                            id: card

                            property alias text: textSymbol.text
                            property alias textCoor: textSymbol.color
                            property int letterState: -1

                            width:  (table.width - (table.columnCount - 1) * columns.spacing  - 2 * columns.padding) / table.columnCount
                            height: (table.height - (table.rowCount - 1) * rows.spacing - 2 * columns.padding) / table.rowCount

                            border.width: 1
                            border.color: "yellow"
                            radius: 10

                            color: "black"

                            onLetterStateChanged: turnOver()

                            function turnOver()
                            {
                                turnOverAnimation.start()
                            }

                            function showFace()
                            {
                                function letterState2backgroundColor(state)
                                {
                                    switch (state)
                                    {
                                        case Engine.LetterState.IncorrectSymbol:
                                            return "#666666"
                                        case Engine.LetterState.CorrectSymbol:
                                            return "#ffffff"
                                        case Engine.LetterState.CorrectSymbolAndPosition:
                                            return "#ffff00"
                                    }

                                    return "#ff0000"
                                }

                                function letterState2textColor(state)
                                {

                                    switch (state)
                                    {
                                        case Engine.LetterState.IncorrectSymbol:
                                            return "#ffffff"
                                        case Engine.LetterState.CorrectSymbol:
                                            return "#666666"
                                        case Engine.LetterState.CorrectSymbolAndPosition:
                                            return "#000000"
                                    }

                                    return "#ff0000"
                                }

                                color = letterState2backgroundColor(letterState);
                                textSymbol.color = letterState2textColor(letterState);
                            }

                            Text
                            {
                                id: textSymbol
                                color: "#ffffff"

                                anchors.fill: parent
                                fontSizeMode: Text.Fit
                                font.pixelSize: 72
                                font.weight: 1
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter

                                transform: Rotation
                                {
                                    id: letterTransformation

                                    origin.x: width / 2
                                    origin.y: height / 2
                                    axis { x: 0; y: 1; z: 0 }
                                }

                                function turnOver()
                                {
                                    letterTransformation.angle += 180
                                }
                            }

                            MouseArea
                            {
                                anchors.fill: parent
                                hoverEnabled: true

                                onEntered: showTip()
                                onExited: toolTip.hide()

                                function showTip()
                                {
                                    function leterState2tipMessage(letterState)
                                    {
                                        switch (letterState)
                                        {
                                            case Engine.LetterState.IncorrectSymbol:
                                                return "The world havn't the letter"
                                            case Engine.LetterState.CorrectSymbol:
                                                return "Incorrect letter position"
                                            case Engine.LetterState.CorrectSymbolAndPosition:
                                                return "The world have the letter in the position"
                                        }

                                        return "Empty cell"
                                    }

                                    const tipMessage = leterState2tipMessage(letterState)

                                    if (!tipMessage.isEmpty)
                                        toolTip.show(tipMessage)
                                }
                            }

                            ToolTip
                            {
                                id: toolTip
                            }

                            transform: Rotation
                            {
                                id: transformation

                                origin.x: width / 2
                                origin.y: height / 2
                                axis { x: 0; y: 1; z: 0 }
                            }

                            PropertyAnimation
                            {
                                id: turnOverAnimation

                                target: transformation
                                properties: "angle"
                                to: 90
                                duration: 500

                                onFinished:
                                {
                                    textSymbol.turnOver()
                                    card.showFace()
                                    continueTurnOverAnimation.start()
                                }
                            }

                            PropertyAnimation
                            {
                                id: continueTurnOverAnimation

                                target: transformation
                                properties: "angle"
                                to: 180
                                duration: 500
                            }
                        }
                    }
                }
            }
        }
    }

    Text
    {
        id: messageBox

        visible: false

        style: Text.Outline
        styleColor: "red"

        font.pixelSize: 0.1 * Math.round(Math.sqrt(parent.width*parent.width + parent.height*parent.height))
        anchors.centerIn: parent
    }
}
