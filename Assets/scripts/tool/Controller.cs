using UnityEngine;
using System.Collections;
using System.Collections.Generic;

// Cross-platform control here
public class Controller
{
    public class MouseOrTouch
    {
        public Vector3 pos;             // Current position of the mouse or touch event
        public Vector3 lastPos;         // Previous position of the mouse or touch event
        public Vector3 delta;           // Delta since last update

        public bool isPressed;
        public bool isMoved;
    }

    static Controller sInstance;

    public static Controller instance
    {
        get
        {
            if (sInstance == null)
            {
                sInstance = new Controller();
            }
            return sInstance;
        }
    }

    private Vector3 downPosition = Vector3.zero;
    private Vector3 releasePosition = Vector3.zero;
    private Vector3 currentPosition = Vector3.zero;

    private float MOVE_DELTA = 20;

    private float deltaX, deltaY;
    private float deltaPinch;
    private bool touchMoveAway;

    private bool isDown;
    private bool isPressed;
    private bool isReleased;
    private bool isClicked;
    private bool isPinch;

    private Dictionary<int, RaycastHit> mRaycastHits_CurretPosition;
    private Dictionary<int, RaycastHit[]> mRaycastHits_CurretPositions;

    private float PINCH_DELTA = 5;
    private float oldDistance_touch;
    private float newDistance_touch;

    // List of currently active touches
    static Dictionary<int, MouseOrTouch> mTouches = new Dictionary<int, MouseOrTouch>();

    private static float accelerometerUpdateInterval = 1.0f / Serclimax.Constants.Frame_Limitation;

    private static float lowPassKernelWidthInSeconds = 1.0f;

    private static float shakeDetectionThreshold = 2.0f;

    private float lowPassFilterFactor = accelerometerUpdateInterval / lowPassKernelWidthInSeconds;

    private Vector3 lowPassValue = Vector3.zero;

    private Vector3 acceleration;

    private Vector3 deltaAcceleration;

    private bool isShaking;

    public Controller()
    {
        MOVE_DELTA = Screen.width * 0.02f;
        mRaycastHits_CurretPosition = new Dictionary<int, RaycastHit>();
        mRaycastHits_CurretPositions = new Dictionary<int, RaycastHit[]>();

        shakeDetectionThreshold *= shakeDetectionThreshold;
        lowPassValue = Input.acceleration;
    }

    public void Clear()
    {
        deltaX = deltaY = 0;
        isDown = isPressed = isReleased = isClicked = isPinch = false;
        deltaPinch = 0;
        currentPosition = Vector3.zero;
        touchMoveAway = false;
        mRaycastHits_CurretPosition.Clear();
        mRaycastHits_CurretPositions.Clear();
        oldDistance_touch = 0;
        newDistance_touch = 0;

        mTouches.Clear();
    }

    // if Event is Catched control in Controller, return true
    public bool UpdateControl()
    {
        bool catchEvent = false;
        deltaX = deltaY = 0;
        isDown = isPressed = isReleased = isClicked = isPinch = false;
        deltaPinch = 0;
        mRaycastHits_CurretPosition.Clear();
        mRaycastHits_CurretPositions.Clear();

        if (Application.platform == RuntimePlatform.WindowsEditor || Application.platform == RuntimePlatform.WindowsPlayer || Application.platform == RuntimePlatform.OSXEditor)
        {
            deltaPinch = Input.GetAxis("Mouse ScrollWheel") * 100;

            if (deltaPinch != 0)
            {
                isPinch = true;
                mTouches.Clear();

                catchEvent = true;
            }
            else if (Input.GetMouseButtonDown(0))
            {
                GetTouch(0).pos = Input.mousePosition;
                GetTouch(0).isPressed = true;
                downPosition = Input.mousePosition;
                currentPosition = downPosition;
                touchMoveAway = false;
                isDown = true;

                catchEvent = true;
            }
            else if (Input.GetMouseButton(0))
            {
                GetTouch(0).lastPos = GetTouch(0).pos;
                GetTouch(0).pos = Input.mousePosition;
                GetTouch(0).delta = GetTouch(0).lastPos - GetTouch(0).pos;
                GetTouch(0).isPressed = false;
                GetTouch(0).isMoved = true;

                Vector3 deltaMouse = Input.mousePosition - currentPosition;
                deltaX = -deltaMouse.x;
                deltaY = -deltaMouse.y;
                currentPosition = Input.mousePosition;

                if (Mathf.Abs(downPosition.x - currentPosition.x) > MOVE_DELTA ||
                    Mathf.Abs(downPosition.y - currentPosition.y) > MOVE_DELTA)
                {
                    touchMoveAway = true;
                }
                isPressed = true;

                catchEvent = true;
            }
            else if (Input.GetMouseButtonUp(0))
            {
                RemoveTouch(0);

                isReleased = true;
                isClicked = !touchMoveAway;
                releasePosition = currentPosition;
                touchMoveAway = false;
            }
            else
            {
                mTouches.Clear();
                currentPosition = Vector3.zero;
                touchMoveAway = false;
            }
        }

        for (int i = 0; i < Input.touchCount; ++i)
        {
            Touch touch = Input.GetTouch(i);
            MouseOrTouch mt = GetTouch(touch.fingerId);

            if (touch.phase == TouchPhase.Began)
            {
                mt.pos = touch.position;
                mt.isPressed = true;
                mt.isMoved = false;
            }
            else if (touch.phase == TouchPhase.Moved)
            {
                mt.lastPos = mt.pos;
                mt.pos = touch.position;
                mt.delta = mt.lastPos - mt.pos;
                mt.isPressed = false;
                mt.isMoved = true;
            }
            else if (touch.phase == TouchPhase.Ended || touch.phase == TouchPhase.Canceled)
            {
                RemoveTouch(touch.fingerId);
            }
        }

        if (Application.platform == RuntimePlatform.Android || Application.platform == RuntimePlatform.IPhonePlayer)
        {
            int fingerCount = Input.touchCount;
            if (fingerCount == 0)
            {
                mTouches.Clear();
            }
            else if (fingerCount == 1)
            {
                isPressed = true;
                oldDistance_touch = 0;

                if (Input.GetTouch(0).phase == TouchPhase.Began)
                {
                    touchMoveAway = false;
                    downPosition = Input.GetTouch(0).position;
                    currentPosition = downPosition;
                    isDown = true;
                    isPressed = false;

                    catchEvent = true;
                }

                if (Input.GetTouch(0).phase == TouchPhase.Moved)
                {
                    deltaX = -Input.GetTouch(0).position.x + currentPosition.x;
                    deltaY = -Input.GetTouch(0).position.y + currentPosition.y;
                    currentPosition = Input.GetTouch(0).position;

                    if (Mathf.Abs(downPosition.x - currentPosition.x) > MOVE_DELTA ||
                        Mathf.Abs(downPosition.y - currentPosition.y) > MOVE_DELTA)
                    {
                        touchMoveAway = true;
                    }

                    catchEvent = true;
                }

                if (Input.GetTouch(0).phase == TouchPhase.Ended)
                {
                    isReleased = true;
                    isClicked = !touchMoveAway;
                    isPressed = false;
                    releasePosition = Input.GetTouch(0).position;
                    currentPosition = releasePosition;
                }
            }
            else if (fingerCount == 2)
            {
                currentPosition = Vector3.zero;
                touchMoveAway = false;

                if (oldDistance_touch == 0)
                {
                    oldDistance_touch = Vector2.Distance(Input.GetTouch(0).position, Input.GetTouch(1).position);
                }
                else
                {
                    if (Input.GetTouch(0).phase == TouchPhase.Moved || Input.GetTouch(1).phase == TouchPhase.Moved)
                    {
                        newDistance_touch = Vector2.Distance(Input.GetTouch(0).position, Input.GetTouch(1).position);

                        if (Mathf.Abs(newDistance_touch - oldDistance_touch) > PINCH_DELTA)
                        {
                            isPinch = true;
                            deltaPinch = newDistance_touch - oldDistance_touch;
                            oldDistance_touch = newDistance_touch;
                        }
                    }
                }

                catchEvent = true;
            }
            else
            {
                currentPosition = Vector3.zero;
                touchMoveAway = false;
            }
        }

        acceleration = Input.acceleration;
        lowPassValue = Vector3.Lerp(lowPassValue, acceleration, lowPassFilterFactor);
        deltaAcceleration = acceleration - lowPassValue;
        isShaking = deltaAcceleration.sqrMagnitude >= shakeDetectionThreshold;

        return catchEvent;
    }

    MouseOrTouch GetTouch(int id)
    {
        MouseOrTouch touch = null;

        if (!mTouches.TryGetValue(id, out touch))
        {
            touch = new MouseOrTouch();
            mTouches.Add(id, touch);
        }
        return touch;
    }

    void RemoveTouch(int id)
    {
        mTouches.Remove(id);
    }

    public Dictionary<int, MouseOrTouch> GetTouches()
    {
        return mTouches;
    }

    public bool IsDown()
    {
        return isDown;
    }

    public bool IsPressed()
    {
        return isPressed;
    }

    public bool IsDragged()
    {
        return isPressed && touchMoveAway;
    }

    public bool IsReleased()
    {
        return isReleased;
    }

    public bool IsClick()
    {
        return isClicked;
    }

    public bool IsPinch()
    {
        return isPinch;
    }

    public bool IsShaking()
    {
        return isShaking;
    }

    public float GetDeltaX()
    {
        return deltaX;
    }

    public float GetDeltaY()
    {
        return deltaY;
    }

    public float GetPinchDelta()
    {
        return deltaPinch;
    }

    public Vector3 GetDownPosition()
    {
        return downPosition;
    }

    public Vector3 GetCurrentPosition()
    {
        return currentPosition;
    }

    public Vector3 GetReleasePosition()
    {
        return releasePosition;
    }

    public RaycastHit? GetHitByCurrentPosition(Camera _camera, int _layerMask)
    {
        if (_camera)
        {
            if (mRaycastHits_CurretPosition.ContainsKey(_layerMask))
            {
                return mRaycastHits_CurretPosition[_layerMask];
            }
            RaycastHit hit;

            Ray ray = _camera.ScreenPointToRay(currentPosition);
            float dist = _camera.farClipPlane - _camera.nearClipPlane;
            if (Physics.Raycast(ray, out hit, dist, _layerMask))
            {
                mRaycastHits_CurretPosition.Add(_layerMask, hit);
                return hit;
            }
        }
        return null;
    }

    public RaycastHit? GetHitByCurrentPosition(int _layerMask)
    {
        return GetHitByCurrentPosition(Camera.main, _layerMask);
    }

    public RaycastHit[] GetHitsByCurrentPosition(Camera _camera, int _layerMask)
    {
        if (_camera)
        {
            if (mRaycastHits_CurretPositions.ContainsKey(_layerMask))
            {
                return mRaycastHits_CurretPositions[_layerMask];
            }

            Ray ray = _camera.ScreenPointToRay(currentPosition);
            RaycastHit[] rayHits = Physics.RaycastAll(ray, 100f, _layerMask);
            if (rayHits != null && rayHits.Length > 0)
            {
                mRaycastHits_CurretPositions.Add(_layerMask, rayHits);
                return rayHits;
            }
        }
        return null;
    }

    public RaycastHit[] GetHitsByCurrentPosition(int _layerMask)
    {
        return GetHitsByCurrentPosition(Camera.main, _layerMask);
    }

    public Vector3 GetHitPositionByCurrentPosition(int _layerMask)
    {
        RaycastHit? hit = GetHitByCurrentPosition(_layerMask);
        if (hit != null)
        {
            return ((RaycastHit)hit).point;
        }
        else
        {
            return Vector3.zero;
        }
    }
}