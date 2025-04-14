using UnityEngine;

public class WorldHUDTimer : WorldHUDComponent
{
    [SerializeField]
    private bool _isEnabled;
    public bool isEnabled
    {
        get
        {
            return _isEnabled;
        }

        set
        {
            _isEnabled = value;
        }
    }

    [SerializeField]
    private long now = 1;

    [SerializeField]
    private uint _timeStamp = 0;
    public uint timeStamp
    {
        get
        {
            return _timeStamp;
        }

        set
        {
            _timeStamp = value;

            if (value == 0)
                _isEnabled = false;
            else
                _isEnabled = true;

            if (_isEnabled && _updateFunction != null)
                _updateFunction.Invoke(now, timeStamp);
        }
    }

    private System.Action<long, uint> _updateFunction;
    public System.Action<long, uint> updateFunction
    {
        set
        {
            _updateFunction = value;

            if (timeStamp != 0 && _updateFunction != null)
                _updateFunction.Invoke(now, timeStamp);
        }

        get
        {
            return _updateFunction;
        }
    }

    private System.Action _onFinish;
    public System.Action onFinish
    {
        set
        {
            _onFinish = value;
        }
    }

    public void Update()
    {
        long now = Serclimax.GameTime.GetSecTime();
        if (this.now != now)
        {
            this.now = now;

            if (_isEnabled && _updateFunction != null)
                _updateFunction.Invoke(now, timeStamp);

            if (_isEnabled && _timeStamp == now && _onFinish != null)
                _onFinish.Invoke();
        }
    }
}
