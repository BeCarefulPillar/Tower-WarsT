using UnityEngine;
using System.Text;
using System.Text.RegularExpressions;

[RequireComponent(typeof(UIInput))]
public class UIInputLogic : MonoBehaviour
{
    public int byteLimit = 0;
    public bool disableCN = false;
    public bool TrimSpace = false;

    private Regex chinese;

    UIInput input;
    // Use this for initialization
    void Start()
    {
        input = GetComponent<UIInput>();
        if (input != null) input.onValidate = Validate;
    }

    char Validate(string text, int pos, char ch)
    {
        if (byteLimit > 0 && Encoding.UTF8.GetByteCount(text + ch) > byteLimit) return (char)0;

        if (disableCN)
        {
            if (chinese == null) chinese = new Regex("^[\u4e00-\u9fa5]{0,}$");
            if (chinese.IsMatch(ch.ToString())) return (char)0;
        }
        if(TrimSpace)
        {
            if (char.IsWhiteSpace(ch)) return (char)0;
        }

        return OValidate(text, pos, ch);
    }

    protected char OValidate(string text, int pos, char ch)
    {
        UIInput.Validation validation = input.validation;
        // Validation is disabled
        if (validation == UIInput.Validation.None || !enabled) return ch;

        if (validation == UIInput.Validation.Integer)
        {
            // Integer number validation
            if (ch >= '0' && ch <= '9') return ch;
            if (ch == '-' && pos == 0 && !text.Contains("-")) return ch;
        }
        else if (validation == UIInput.Validation.Float)
        {
            // Floating-point number
            if (ch >= '0' && ch <= '9') return ch;
            if (ch == '-' && pos == 0 && !text.Contains("-")) return ch;
            if (ch == '.' && !text.Contains(".")) return ch;
        }
        else if (validation == UIInput.Validation.Alphanumeric)
        {
            // All alphanumeric characters
            if (ch >= 'A' && ch <= 'Z') return ch;
            if (ch >= 'a' && ch <= 'z') return ch;
            if (ch >= '0' && ch <= '9') return ch;
        }
        else if (validation == UIInput.Validation.Username)
        {
            // Lowercase and numbers
            if (ch >= 'A' && ch <= 'Z') return (char)(ch - 'A' + 'a');
            if (ch >= 'a' && ch <= 'z') return ch;
            if (ch >= '0' && ch <= '9') return ch;
        }
        else if (validation == UIInput.Validation.Name)
        {
            char lastChar = (text.Length > 0) ? text[Mathf.Clamp(pos, 0, text.Length - 1)] : ' ';
            char nextChar = (text.Length > 0) ? text[Mathf.Clamp(pos + 1, 0, text.Length - 1)] : '\n';

            if (ch >= 'a' && ch <= 'z')
            {
                // Space followed by a letter -- make sure it's capitalized
                if (lastChar == ' ') return (char)(ch - 'a' + 'A');
                return ch;
            }
            else if (ch >= 'A' && ch <= 'Z')
            {
                // Uppercase letters are only allowed after spaces (and apostrophes)
                if (lastChar != ' ' && lastChar != '\'') return (char)(ch - 'A' + 'a');
                return ch;
            }
            else if (ch == '\'')
            {
                // Don't allow more than one apostrophe
                if (lastChar != ' ' && lastChar != '\'' && nextChar != '\'' && !text.Contains("'")) return ch;
            }
            else if (ch == ' ')
            {
                // Don't allow more than one space in a row
                if (lastChar != ' ' && lastChar != '\'' && nextChar != ' ' && nextChar != '\'') return ch;
            }
        }
        return (char)0;
    }
}
