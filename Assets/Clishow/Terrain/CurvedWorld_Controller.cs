using UnityEngine;
using System.Collections;
public enum BEND_TYPE
{
    Unknown,
    ClassicRunner,
    LittlePlanet,
    Universal,
    CylindricalTower,
    Perspective2D
}

public class CurvedWorld_Controller : MonoBehaviour
{
    [HideInInspector]
    public Transform pivotPoint;
    private int _V_CW_PivotPoint_Position_ID;
    [HideInInspector]
    private Vector3 _V_CW_Bend = Vector3.zero;
    private int _V_CW_Bend_ID;
    [HideInInspector]
    private Vector3 _V_CW_Bias = Vector3.zero;
    private int _V_CW_Bias_ID;
    [HideInInspector]
    public float _V_CW_Bend_X;
    private float _V_CW_Bend_X_current = 1f;
    [HideInInspector]
    public float _V_CW_Bend_Y;
    private float _V_CW_Bend_Y_current = 1f;
    [HideInInspector]
    public float _V_CW_Bend_Z;
    private float _V_CW_Bend_Z_current = 1f;
    [HideInInspector]
    public float _V_CW_Bias_X;
    private float _V_CW_Bias_X_current = 1f;
    [HideInInspector]
    public float _V_CW_Bias_Y;
    private float _V_CW_Bias_Y_current = 1f;
    [HideInInspector]
    public float _V_CW_Bias_Z;
    private float _V_CW_Bias_Z_current = 1f;
    public static CurvedWorld_Controller get;
    private void OnEnable()
    {
        this.LoadIDs();
        this.EnableBend();
    }
    private void OnDisable()
    {
        this.DisableBend();
    }
    private void OnDestroy()
    {
        if (CurvedWorld_Controller.get == this)
        {
            CurvedWorld_Controller.get = null;
        }
    }
    private void Start()
    {
        if (CurvedWorld_Controller.get != null && CurvedWorld_Controller.get != this)
        {
            Debug.LogError("There is more then one CurvedWorld Global Controller in the scene.\nPlease ensure there is always exactly one CurvedWorld Global Controller in the scene.\n", CurvedWorld_Controller.get.gameObject);
        }
        CurvedWorld_Controller.get = this;
        this.LoadIDs();
    }
    private void LateUpdate()
    {
        if (CurvedWorld_Controller.get == null)
        {
            CurvedWorld_Controller.get = this;
        }
        if (base.isActiveAndEnabled)
        {
            Shader.SetGlobalVector(this._V_CW_PivotPoint_Position_ID, (this.pivotPoint == null) ? Vector3.zero : this.pivotPoint.transform.position);
            if (this._V_CW_Bend_X_current != this._V_CW_Bend_X || this._V_CW_Bend_Y_current != this._V_CW_Bend_Y || this._V_CW_Bend_Z_current != this._V_CW_Bend_Z)
            {
                this._V_CW_Bend_X_current = this._V_CW_Bend_X;
                this._V_CW_Bend_Y_current = this._V_CW_Bend_Y;
                this._V_CW_Bend_Z_current = this._V_CW_Bend_Z;
                this._V_CW_Bend = new Vector3(this._V_CW_Bend_X, this._V_CW_Bend_Y, this._V_CW_Bend_Z);
                Shader.SetGlobalVector(this._V_CW_Bend_ID, this._V_CW_Bend);
            }
            if (this._V_CW_Bias_X_current != this._V_CW_Bias_X || this._V_CW_Bias_Y_current != this._V_CW_Bias_Y || this._V_CW_Bias_Z_current != this._V_CW_Bias_Z)
            {
                if (this._V_CW_Bias_X < 0f)
                {
                    this._V_CW_Bias_X = 0f;
                }
                if (this._V_CW_Bias_Y < 0f)
                {
                    this._V_CW_Bias_Y = 0f;
                }
                if (this._V_CW_Bias_Z < 0f)
                {
                    this._V_CW_Bias_Z = 0f;
                }
                this._V_CW_Bias_X_current = this._V_CW_Bias_X;
                this._V_CW_Bias_Y_current = this._V_CW_Bias_Y;
                this._V_CW_Bias_Z_current = this._V_CW_Bias_Z;
                this._V_CW_Bias = new Vector3(this._V_CW_Bias_X, this._V_CW_Bias_Y, this._V_CW_Bias_Z);
                Shader.SetGlobalVector(this._V_CW_Bias_ID, this._V_CW_Bias);
            }
        }
    }
    private void LoadIDs()
    {
        this._V_CW_PivotPoint_Position_ID = Shader.PropertyToID("_V_CW_PivotPoint_Position");
        this._V_CW_Bend_ID = Shader.PropertyToID("_V_CW_Bend");
        this._V_CW_Bias_ID = Shader.PropertyToID("_V_CW_Bias");
    }
    public void Reset()
    {
        Shader.SetGlobalVector(this._V_CW_PivotPoint_Position_ID, (this.pivotPoint == null) ? Vector3.zero : this.pivotPoint.transform.position);
        this._V_CW_Bend = Vector3.zero;
        this._V_CW_Bias = Vector3.zero;
        this._V_CW_Bend_X_current = (this._V_CW_Bend_X = 0f);
        this._V_CW_Bend_Y_current = (this._V_CW_Bend_Y = 0f);
        this._V_CW_Bend_Z_current = (this._V_CW_Bend_Z = 0f);
        this._V_CW_Bias_X_current = (this._V_CW_Bias_X = 0f);
        this._V_CW_Bias_Y_current = (this._V_CW_Bias_Y = 0f);
        this._V_CW_Bias_Z_current = (this._V_CW_Bias_Z = 0f);
        Shader.SetGlobalVector(this._V_CW_Bend_ID, this._V_CW_Bend);
        Shader.SetGlobalVector(this._V_CW_Bias_ID, this._V_CW_Bias);
    }
    public void ForceUpdate()
    {
        this.LoadIDs();
        Shader.SetGlobalVector(this._V_CW_PivotPoint_Position_ID, (this.pivotPoint == null) ? Vector3.zero : this.pivotPoint.transform.position);
        this._V_CW_Bend = new Vector3(this._V_CW_Bend_X, this._V_CW_Bend_Y, this._V_CW_Bend_Z);
        Shader.SetGlobalVector(this._V_CW_Bend_ID, this._V_CW_Bend);
        this._V_CW_Bias = new Vector3(this._V_CW_Bias_X, this._V_CW_Bias_Y, this._V_CW_Bias_Z);
        Shader.SetGlobalVector(this._V_CW_Bias_ID, this._V_CW_Bias);
    }
    public void EnableBend()
    {
        this.ForceUpdate();
    }
    public void DisableBend()
    {
        this.LoadIDs();
        Shader.SetGlobalVector(this._V_CW_PivotPoint_Position_ID, Vector3.zero);
        Shader.SetGlobalVector(this._V_CW_Bend_ID, Vector3.zero);
        Shader.SetGlobalVector(this._V_CW_Bias_ID, Vector3.zero);
    }
    public static Vector3 TransformPoint(Vector3 _transformPoint, BEND_TYPE _bendType, Vector3 _bendSize, Vector3 _bendBias, Vector3 _pivotPoint)
    {
        switch (_bendType)
        {
            case BEND_TYPE.ClassicRunner:
                {
                    Vector3 vector = _transformPoint - _pivotPoint;
                    float num = Mathf.Max(0f, vector.z - _bendBias.x);
                    float num2 = Mathf.Max(0f, vector.z - _bendBias.y);
                    vector = new Vector3(-_bendSize.y * num2 * num2, _bendSize.x * num * num, 0f) * 0.001f;
                    return _transformPoint + vector;
                }
            case BEND_TYPE.LittlePlanet:
                {
                    Vector3 vector2 = _transformPoint - _pivotPoint;
                    float num3 = Mathf.Max(0f, Mathf.Abs(vector2.z) - _bendBias.x) * ((vector2.z < 0f) ? -1f : 1f);
                    float num4 = Mathf.Max(0f, Mathf.Abs(vector2.x) - _bendBias.z) * ((vector2.x < 0f) ? -1f : 1f);
                    vector2 = new Vector3(0f, (_bendSize.x * num3 * num3 + _bendSize.z * num4 * num4) * 0.001f, 0f);
                    return _transformPoint + vector2;
                }
            case BEND_TYPE.Universal:
                {
                    Vector3 vector3 = _transformPoint - _pivotPoint;
                    float num5 = Mathf.Max(0f, Mathf.Abs(vector3.z) - _bendBias.x) * ((vector3.z < 0f) ? -1f : 1f);
                    float num6 = Mathf.Max(0f, Mathf.Abs(vector3.z) - _bendBias.y) * ((vector3.z < 0f) ? -1f : 1f);
                    float num7 = Mathf.Max(0f, Mathf.Abs(vector3.x) - _bendBias.z) * ((vector3.x < 0f) ? -1f : 1f);
                    vector3 = new Vector3(-_bendSize.y * num6 * num6, _bendSize.x * num5 * num5 + num7 * num7 * _bendSize.z, 0f) * 0.001f;
                    return _transformPoint + vector3;
                }
            case BEND_TYPE.CylindricalTower:
                {
                    Vector3 vector4 = _transformPoint - _pivotPoint;
                    float num8 = Mathf.Max(0f, Mathf.Abs(vector4.y) - _bendBias.x) * ((vector4.y < 0f) ? -1f : 1f);
                    float num9 = Mathf.Max(0f, Mathf.Abs(vector4.x) - _bendBias.y) * ((vector4.x < 0f) ? -1f : 1f);
                    vector4 = new Vector3(0f, 0f, (_bendSize.y * num9 * num9 + _bendSize.x * num8 * num8) * 0.001f);
                    return _transformPoint + vector4;
                }
            case BEND_TYPE.Perspective2D:
                {
                    Vector3 vector5 = _transformPoint - _pivotPoint;
                    vector5 = Camera.main.worldToCameraMatrix.MultiplyPoint(vector5);
                    float num10 = Mathf.Max(0f, Mathf.Abs(vector5.y) - _bendBias.x) * ((vector5.y < 0f) ? -1f : 1f);
                    num10 *= num10;
                    float num11 = Mathf.Max(0f, Mathf.Abs(vector5.x) - _bendBias.y) * ((vector5.x < 0f) ? -1f : 1f);
                    num11 *= num11;
                    Vector3 vector6 = vector5;
                    vector6.z -= (_bendSize.x * num10 + _bendSize.y * num10) * 0.001f;
                    return Camera.main.worldToCameraMatrix.inverse.MultiplyPoint(vector6);
                }
            default:
                return _transformPoint;
        }
    }
    public Vector3 TransformPoint(Vector3 _transformPoint, BEND_TYPE _bendType)
    {
        if (!base.enabled)
        {
            return _transformPoint;
        }
        return CurvedWorld_Controller.TransformPoint(_transformPoint, _bendType, this.GetBend(), this.GetBias(), (this.pivotPoint == null) ? Vector3.zero : this.pivotPoint.position);
    }
    public Vector3 GetBend()
    {
        return this._V_CW_Bend;
    }
    public void SetBend(Vector3 _newBend)
    {
        this._V_CW_Bend_X = _newBend.x;
        this._V_CW_Bend_Y = _newBend.y;
        this._V_CW_Bend_Z = _newBend.z;
        this._V_CW_Bend = new Vector3(this._V_CW_Bend_X, this._V_CW_Bend_Y, this._V_CW_Bend_Z);
    }
    public Vector3 GetBias()
    {
        return this._V_CW_Bias;
    }
    public void SetBias(Vector3 _newBias)
    {
        if (_newBias.x < 0f)
        {
            _newBias.x = 0f;
        }
        if (_newBias.y < 0f)
        {
            _newBias.y = 0f;
        }
        if (_newBias.z < 0f)
        {
            _newBias.z = 0f;
        }
        this._V_CW_Bias_X = _newBias.x;
        this._V_CW_Bias_Y = _newBias.y;
        this._V_CW_Bias_Z = _newBias.z;
        this._V_CW_Bias = new Vector3(this._V_CW_Bias_X, this._V_CW_Bias_Y, this._V_CW_Bias_Z);
    }
}
