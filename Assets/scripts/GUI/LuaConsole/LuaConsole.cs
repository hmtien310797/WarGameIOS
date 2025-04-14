using UnityEngine;
using System.Collections;
using System;
using LuaInterface;
using System.Collections.Generic;

public class LuaConsole : MonoBehaviour
{
    private static LuaConsole instance;

    public UITextList textList;

    public UIInput input;

    private List<string> historyList;

    private int historyIndex;

    void Awake()
    {
        instance = this;

        historyList = new List<string>();

        Application.logMessageReceived += HandleLog;
    }

    public static LuaConsole Instance
    {
        get
        {
            return instance;
        }
    }

    void OnEnable()
    {
        input.isSelected = true;
    }

    void OnDestroy()
    {
        Application.logMessageReceived -= HandleLog;
    }

    public void HandleLog(string logString, string stackTrace, LogType logType)
    {

        if (logType == LogType.Error || logType == LogType.Exception)
        {
            textList.Add("[ff0000]" + logString.Replace("[", "[[c]") + "[-]");
        }
        else
        {
            textList.Add(logString.Replace("[", "[[c]"));
        }
    }

    public void HandleSubmit()
    {
        string text = input.value;
        if (!string.IsNullOrEmpty(text))
        {
            textList.Add(text.Replace("[", "[[c]"));
            if (historyList.Count == 0 || historyList[historyList.Count - 1] != text)
            {
                historyList.Add(text);
            }
            historyIndex = historyList.Count;

            if (historyList.Count > 100)
            {
                historyList.RemoveAt(0);
            }

            try
            {
                LuaClient.GetMainState().DoString(text);
            }
            catch (Exception e)
            {
                Debug.LogException(e);
            }

            input.value = "";
        }
    }

    void Update()
    {
        if (Input.GetKeyDown(KeyCode.L) && (Input.GetKey(KeyCode.LeftControl) || Input.GetKey(KeyCode.LeftCommand)))
        {
            textList.Clear();
        }

        if (historyList.Count > 0)
        {
            if (Input.GetKeyDown(KeyCode.UpArrow))
            {
                historyIndex--;
                historyIndex = Math.Max(0, historyIndex);
                input.value = historyList[historyIndex];
            }
            else if (Input.GetKeyDown(KeyCode.DownArrow))
            {
                historyIndex++;
                historyIndex = Math.Min(historyIndex, historyList.Count - 1);
                input.value = historyList[historyIndex];
            }
        }
    }
}
