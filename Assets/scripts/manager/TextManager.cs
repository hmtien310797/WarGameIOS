using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Text;

public class TextManager
{
    public enum LANGUAGE
    {
        VN = 0,
        EN = 1, //1
        NA = 2
    };

    public static Dictionary<SystemLanguage, LANGUAGE> SysTolocalMap = new Dictionary<SystemLanguage, LANGUAGE>
    {
        { SystemLanguage.Vietnamese, LANGUAGE.VN },
        { SystemLanguage.English, LANGUAGE.EN },
    };

    public const int LANGUAGE_COUNT = 11;
    static string HEADERNAME = "TEXT_HEAD";

    public const string DefaultLanguage = "EN";

    // Should not changed, it is also used in the protocol: GetUserInfoRequest
    public static string[] FILENAME = new string[2]
    {
        "VN",
        "EN",
    };

    public static bool USE_EASTEN_CHARACTER = false;

    public LANGUAGE currentLanguage;

    string[] texts;
    int textsCount;
    Dictionary<string, int> headerDictionary = new Dictionary<string, int>();

    private bool mHasLoadHeader;
    private LANGUAGE mCurrentLoadedLanguage;

    static TextManager instance;

    public static TextManager Instance
    {
        get
        {
            if (instance == null)
            {
                instance = new TextManager();
            }

            return instance;
        }
    }

    private TextManager()
    {
        currentLanguage = LANGUAGE.NA;
        Clear();
    }

    public void Clear()
    {
        mHasLoadHeader = false;
        mCurrentLoadedLanguage = LANGUAGE.NA;
        USE_EASTEN_CHARACTER = false;
    }

    private void LoadHeader()
    {
        bool result = ReadTextFile(HEADERNAME);

        if (result)
        {
            headerDictionary.Clear();
            for (int i = 0; i < textsCount; i++)
            {
                headerDictionary.Add(texts[i], i);
            }

            texts = null;
            textsCount = 0;
        }

        mHasLoadHeader = true;
    }

    public bool LoadLanguage4Prefs()
    {
        if (string.IsNullOrEmpty(GameSetting.instance.option.mLanguage))
            return false;
        return LoadLanguage((LANGUAGE)System.Enum.Parse(typeof(LANGUAGE), GameSetting.instance.option.mLanguage));
    }

    public bool LoadLanguage(LANGUAGE _lan)
    {
        bool result = true;

        if (!mHasLoadHeader)
        {
            LoadHeader();
        }

        if (mCurrentLoadedLanguage != _lan && _lan != LANGUAGE.NA)
        {
            currentLanguage = _lan;
            mCurrentLoadedLanguage = _lan;
            int languageId = (int)mCurrentLoadedLanguage;
            if (languageId < LANGUAGE_COUNT)
            {
                result = ReadTextFile(FILENAME[languageId]);
            }
            else
            {
                result = false;
            }

            if (!result)
            {
                texts = null;
                textsCount = 0;
            }
        }

        return result;
    }

    public bool ReloadLanguage()
    {
        bool result = true;

        if (!mHasLoadHeader)
        {
            LoadHeader();
        }

        if (mCurrentLoadedLanguage != currentLanguage && currentLanguage != LANGUAGE.NA)
        {
            mCurrentLoadedLanguage = currentLanguage;

            USE_EASTEN_CHARACTER = false;


            int languageId = (int)currentLanguage;
            if (languageId < LANGUAGE_COUNT)
            {
                result = ReadTextFile(FILENAME[languageId]);
            }
            else
            {
                result = false;
            }

            if (!result)
            {
                texts = null;
                textsCount = 0;
            }
        }

        return result;
    }

    public void SetCurLanguage(LANGUAGE _lan)
    {
        currentLanguage = _lan;
    }

    public LANGUAGE GetCurrentLanguage()
    {
        return currentLanguage;
    }

    public int GetCurrentLanguageID()
    {
        return (int)currentLanguage;
    }

    public string GetText(int _id)
    {
        if (texts != null && _id >= 0 && _id < textsCount)
        {
            if (string.IsNullOrEmpty(texts[_id]))
                return "WGAME";

            return texts[_id];
        }
        else
        {
            return string.Empty;
        }
    }

    public string GetText(string _key)
    {
        if (_key == null || _key == string.Empty) return string.Empty;
        int _id = -1;
        headerDictionary.TryGetValue(_key, out _id);
        return GetText(_id);
    }

    public string RemoveColor(string _str)
    {
        if (_str == null || _str == string.Empty) return string.Empty;

        string ret = _str;
        int startIndex = ret.Length - 1;
        while (true)
        {
            if (ret.Contains("]"))
            {
                int rightCharIndex = ret.LastIndexOf(']', startIndex);
                if (rightCharIndex >= 0)
                {
                    int leftCharIndex = rightCharIndex - 7;
                    if (leftCharIndex >= 0)
                    {
                        char find = ret[leftCharIndex];
                        if (find == '[')
                        {
                            ret = ret.Remove(leftCharIndex, 8);
                            startIndex = leftCharIndex - 1;
                        }
                        else
                        {
                            startIndex--;
                        }
                    }
                    else
                    {
                        break;
                    }
                }
                else
                {
                    break;
                }
            }
            else
            {
                break;
            }
        }

        return ret;
    }

    public bool ContainText(string _key)
    {
        return headerDictionary.ContainsKey(_key);
    }

    public Dictionary<string, int> GetTextHeader()
    {
        return headerDictionary;
    }

    bool ReadTextFile(string _filename)
    {
        TextAsset binaryStream = ResourceLibrary.instance.GetTextAsset(_filename);
        if (binaryStream == null)
        {
            Serclimax.DebugUtils.LogError("Error reading tablesize  " + _filename);
            return false;
        }

        MemoryStream ms = new MemoryStream(binaryStream.bytes);
        BinaryReader br = new BinaryReader(ms, Encoding.Unicode);

        int rows = 0;
        rows = br.ReadInt32();
        if (rows == 0)
        {
            Serclimax.DebugUtils.LogError("Error reading tablesize  " + _filename);
            return false;
        }

        textsCount = rows;
        texts = new string[textsCount];
        for (int i = 0; i < textsCount; i++)
        {
            texts[i] = br.ReadString();
        }
#if !UNITY_METRO
        br.Close();
#endif

        return true;
    }
}