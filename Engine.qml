import QtQuick

Item
{
    id: engine

    property string word

    enum LetterState
    {
        IncorrectSymbol,
        CorrectSymbol,
        CorrectSymbolAndPosition
    }

    // Return a letter state array
    function validate (word: string)
    {
        var states = [];

        for (var i = 0; i < word.length; ++i)
        {
            states[i] = Engine.LetterState.IncorrectSymbol

            for (var j = 0; j < engine.word.length; ++j)
            {
                if (engine.word[j] === word[i]) // the second condition use if word contains only one some letter, but we suggest more
                {
                    if (i == j)
                    {
                        states[i] = Engine.LetterState.CorrectSymbolAndPosition
                        break;
                    }
                    else
                    {
                        states[i] = Engine.LetterState.CorrectSymbol
                    }
                }
            }
        }

        return states
    }
}
