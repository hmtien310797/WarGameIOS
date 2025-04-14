using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using System.Linq;

namespace Clishow
{
    public class PCTrail : System.IDisposable
    {
        public CircularBuffer<PCTrailPoint> Points;
        public Mesh Mesh;

        public Vector3[] verticies;
        public Vector3[] normals;
        public Vector2[] uvs;
        public Color[] colors;
        public int[] indicies;
        public int activePointCount;

        public bool IsActiveTrail = false;

        public PCTrail(int numPoints)
        {
            Mesh = new Mesh();
            Mesh.MarkDynamic();

            verticies = new Vector3[2 * numPoints];
            normals = new Vector3[2 * numPoints];
            uvs = new Vector2[2 * numPoints];
            colors = new Color[2 * numPoints];
            indicies = new int[2 * (numPoints) * 3];

            Points = new CircularBuffer<PCTrailPoint>(numPoints);
        }

        #region Implementation of IDisposable

        public void Dispose()
        {
            if (Mesh != null)
            {
                if (Application.isEditor)
                    UnityEngine.Object.DestroyImmediate(Mesh, true);
                else
                    UnityEngine.Object.Destroy(Mesh);
            }

            Points.Clear();
            Points = null;
        }

        #endregion
    }

    public class PCTrailPoint
    {
        public Vector3 Forward;
        public Vector3 Position;
        public int PointNumber;

        private float _timeActive = 0;
        private float _distance;

        public virtual void Update(float deltaTime)
        {
            _timeActive += deltaTime;
        }

        public float TimeActive()
        {
            return _timeActive;
        }

        public void SetTimeActive(float time)
        {
            _timeActive = time;
        }

        public void SetDistanceFromStart(float distance)
        {
            _distance = distance;
        }

        public float GetDistanceFromStart()
        {
            return _distance;
        }
    }

    [System.Serializable]
    public class PCTrailRendererData
    {
        public Material TrailMaterial;
        public float Lifetime = 1;
        public bool UsingSimpleSize = false;
        public float FadeSize = 1;
        public float SimpleSizeOverLifeStart;
        public float SimpleSizeOverLifeEnd;
        public AnimationCurve SizeOverLife = new AnimationCurve();
        public bool UsingSimpleColor = false;
        public Color SimpleColorOverLifeStart;
        public Color SimpleColorOverLifeEnd;
        public Gradient ColorOverLife;
        public bool StretchSizeToFit;
        public bool StretchColorToFit;
        public float MaterialTileLength = 0;
        public bool UseForwardOverride;
        public Vector3 ForwardOverride;
        public bool EnableForwardOverride;
    }

    public class PCTrailObj
    {
        public float FadeValue = 1;
        public float DestroyTime = 0;
        public PCTrailRendererData TrailData;
        public bool Emit = false;
        public float MinVertexDistance = 0.5f;
        public int MaxNumberOfPoints = 2;
        public float DelayLifeTimeUnitTime = 0.5f;
        private Vector3 _lastPosition;
        private float _distanceMoved;

        private CsTrailRenderer mRenderer = null;
        private bool _emit;
        private bool _noDecay;

        private PCTrail _activeTrail;
        private Vector3 _pos;
        private Vector3 _dir;
        private float mLifeTime = 0;
        private float mTotalDestroyTime = 0;
        

        public PCTrailObj(CsTrailRenderer renderer)
        {
            mRenderer = renderer;
        }

        public void Awake(Vector3 pos,Vector3 dir,PCTrailRendererData data)
        {
            mLifeTime = 0;
            _pos = pos;
            _dir = dir.normalized;
            _emit = Emit;
            TrailData = data;
            if(TrailData == null)
            {
                Reset();
            }
            if (_emit)
            {
                _activeTrail = new PCTrail(GetMaxNumberOfPoints());
                _activeTrail.IsActiveTrail = true;
                OnStartEmit();
            }
        }

        public void UpdateDestroyTime()
        {
            int c = (int)(mLifeTime / DelayLifeTimeUnitTime);
            DestroyTime = TrailData.Lifetime*c;
            mTotalDestroyTime = DestroyTime;
        }

        public void Update()
        {
            if (_activeTrail != null)
            {
                mRenderer.PushRenderQueue(_activeTrail);
            }
        }

        public void Update(Vector3 pos,Vector3 dir)
        {
            mLifeTime += Time.deltaTime;
            if(_emit)
            {
                _distanceMoved += Vector3.Distance(_pos, _lastPosition);

                if (_distanceMoved != 0 && _distanceMoved >= MinVertexDistance)
                {
                    AddPoint(new PCTrailPoint(), _pos);
                    _distanceMoved = 0;
                }

                _lastPosition = _pos;
                _pos = pos;
                _dir = dir.normalized;
            }

            if (_activeTrail != null)
            {
                UpdatePoints(_activeTrail, Time.deltaTime);
                UpdateTrail(_activeTrail, Time.deltaTime);
                GenerateMesh(_activeTrail);
                mRenderer.PushRenderQueue(_activeTrail);
            }

            CheckEmitChange();
        }

        public void Destroy()
        {
            if (_activeTrail != null)
            {
                _activeTrail.Dispose();
                _activeTrail = null;
            }
        }

        private  void OnStopEmit()
        {

        }

        private void OnStartEmit()
        {
            
            _lastPosition = _pos;
            _distanceMoved = 0;
        }

        private void OnTranslate(Vector3 t)
        {
            _lastPosition += t;
        }

        private int GetMaxNumberOfPoints()
        {
            return MaxNumberOfPoints;
        }

        public void Reset()
        {
            if (TrailData == null)
                TrailData = new PCTrailRendererData();

            TrailData.Lifetime = 1;

            TrailData.UsingSimpleColor = false;
            TrailData.UsingSimpleSize = false;

            TrailData.ColorOverLife = new Gradient();
            TrailData.SimpleColorOverLifeStart = Color.white;
            TrailData.SimpleColorOverLifeEnd = new Color(1, 1, 1, 0);

            TrailData.SizeOverLife = new AnimationCurve(new Keyframe(0, 1), new Keyframe(1, 0));
            TrailData.SimpleSizeOverLifeStart = 1;
            TrailData.SimpleSizeOverLifeEnd = 0;
        }

        protected virtual void InitialiseNewPoint(PCTrailPoint newPoint)
        {

        }

        protected virtual void UpdateTrail(PCTrail trail, float deltaTime)
        {

        }

        protected void AddPoint(PCTrailPoint newPoint, Vector3 pos)
        {
            if (_activeTrail == null)
                return;

            newPoint.Position = pos;
            newPoint.PointNumber = _activeTrail.Points.Count == 0 ? 0 : _activeTrail.Points[_activeTrail.Points.Count - 1].PointNumber + 1;
            InitialiseNewPoint(newPoint);

            newPoint.SetDistanceFromStart(_activeTrail.Points.Count == 0
                                              ? 0
                                              : _activeTrail.Points[_activeTrail.Points.Count - 1].GetDistanceFromStart() + Vector3.Distance(_activeTrail.Points[_activeTrail.Points.Count - 1].Position, pos));

            if (TrailData.UseForwardOverride)
            {
                newPoint.Forward = TrailData.EnableForwardOverride
                                       ? _dir
                                       : TrailData.ForwardOverride.normalized;
            }

            _activeTrail.Points.Add(newPoint);
        }

        private void RefrushEndMesh(PCTrail trail)
        {
            if(mTotalDestroyTime == 0 || trail.Mesh == null)
                return;

            if(trail.Points == null)
                return;

            int vertIndex = 0;
            float a = DestroyTime / mTotalDestroyTime;
            Vector3 camForward = Camera.main != null ? Camera.main.transform.forward : Vector3.forward;
            for (int i = 0; i < trail.Points.Count; i++)
            {
                PCTrailPoint p = trail.Points[i];

                if (TrailData.UseForwardOverride && TrailData.EnableForwardOverride)
                    camForward = p.Forward;

                Vector3 cross = Vector3.zero;
                if (i < trail.Points.Count - 1)
                {
                    cross =
                        Vector3.Cross((trail.Points[i + 1].Position - p.Position).normalized, camForward).
                            normalized;
                }
                else
                {
                    cross =
                        Vector3.Cross((p.Position - trail.Points[i - 1].Position).normalized, camForward).
                            normalized;
                }

                Color c = trail.colors[i];
                c.a *= a;

                float s = 0;
                if(i == 0 || i == trail.Points.Count -1)
                {
                    s = Mathf.Lerp(TrailData.SimpleSizeOverLifeEnd, TrailData.SimpleSizeOverLifeStart, 1-a);
                }
                else
                s = Mathf.Lerp(TrailData.SimpleSizeOverLifeEnd, TrailData.FadeSize, 1-a);


                trail.verticies[vertIndex] = p.Position + cross * s;
                
                trail.colors[vertIndex] = c;
                vertIndex++;
                trail.verticies[vertIndex] = p.Position - cross * s;
                trail.colors[vertIndex] = c;
                vertIndex++;
            }

            trail.Mesh.vertices = trail.verticies;
            trail.Mesh.colors = trail.colors;
        }

        private void GenerateMesh(PCTrail trail)
        {
            trail.Mesh.Clear(false);

            Vector3 camForward = Camera.main != null ? Camera.main.transform.forward : Vector3.forward;

            if (TrailData.UseForwardOverride)
            {
                camForward = TrailData.ForwardOverride.normalized;
            }

            trail.activePointCount = NumberOfActivePoints(trail);

            if (trail.activePointCount < 2)
                return;


            int vertIndex = 0;
            for (int i = 0; i < trail.Points.Count; i++)
            {
                PCTrailPoint p = trail.Points[i];
                float timeAlong = p.TimeActive() / TrailData.Lifetime;

                if (p.TimeActive() > TrailData.Lifetime)
                {
                    continue;
                }

                if (TrailData.UseForwardOverride && TrailData.EnableForwardOverride)
                    camForward = p.Forward;

                Vector3 cross = Vector3.zero;

                if (i < trail.Points.Count - 1)
                {
                    cross =
                        Vector3.Cross((trail.Points[i + 1].Position - p.Position).normalized, camForward).
                            normalized;
                }
                else
                {
                    cross =
                        Vector3.Cross((p.Position - trail.Points[i - 1].Position).normalized, camForward).
                            normalized;
                }


                //yuck! lets move these into their own functions some time
                Color c = TrailData.StretchColorToFit ?
                    (TrailData.UsingSimpleColor ? Color.Lerp(TrailData.SimpleColorOverLifeStart, TrailData.SimpleColorOverLifeEnd, 1 - ((float)vertIndex / (float)trail.activePointCount / 2f)) : TrailData.ColorOverLife.Evaluate(1 - ((float)vertIndex / (float)trail.activePointCount / 2f))) :
                    (TrailData.UsingSimpleColor ? Color.Lerp(TrailData.SimpleColorOverLifeStart, TrailData.SimpleColorOverLifeEnd, timeAlong) : TrailData.ColorOverLife.Evaluate(timeAlong));

                float s = TrailData.StretchSizeToFit ?
                    (TrailData.UsingSimpleSize ? Mathf.Lerp(TrailData.SimpleSizeOverLifeStart, TrailData.SimpleSizeOverLifeEnd, 1 - ((float)vertIndex / (float)trail.activePointCount / 2f)) : TrailData.SizeOverLife.Evaluate(1 - ((float)vertIndex / (float)trail.activePointCount / 2f))) :
                    (TrailData.UsingSimpleSize ? Mathf.Lerp(TrailData.SimpleSizeOverLifeStart, TrailData.SimpleSizeOverLifeEnd, timeAlong) : TrailData.SizeOverLife.Evaluate(timeAlong));

                c.a *= FadeValue;
                s = s+( 1-FadeValue)*TrailData.FadeSize;
                trail.verticies[vertIndex] = p.Position + cross * s;

                if (TrailData.MaterialTileLength <= 0)
                {
                    trail.uvs[vertIndex] = new Vector2((float)vertIndex / (float)trail.activePointCount / 2f, 0);
                }
                else
                {
                    trail.uvs[vertIndex] = new Vector2(p.GetDistanceFromStart() / TrailData.MaterialTileLength, 0);
                }

                trail.normals[vertIndex] = camForward;
                trail.colors[vertIndex] = c;
                vertIndex++;
                trail.verticies[vertIndex] = p.Position - cross * s;

                if (TrailData.MaterialTileLength <= 0)
                {
                    trail.uvs[vertIndex] = new Vector2((float)vertIndex / (float)trail.activePointCount / 2f, 1);
                }
                else
                {
                    trail.uvs[vertIndex] = new Vector2(p.GetDistanceFromStart() / TrailData.MaterialTileLength, 1);
                }

                trail.normals[vertIndex] = camForward;
                trail.colors[vertIndex] = c;

                vertIndex++;
            }

            Vector2 finalPosition = trail.verticies[vertIndex - 1];
            for (int i = vertIndex; i < trail.verticies.Length; i++)
            {
                trail.verticies[i] = finalPosition;
            }

            int indIndex = 0;
            for (int pointIndex = 0; pointIndex < 2 * (trail.activePointCount - 1); pointIndex++)
            {
                if (pointIndex % 2 == 0)
                {
                    trail.indicies[indIndex] = pointIndex;
                    indIndex++;
                    trail.indicies[indIndex] = pointIndex + 1;
                    indIndex++;
                    trail.indicies[indIndex] = pointIndex + 2;
                }
                else
                {
                    trail.indicies[indIndex] = pointIndex + 2;
                    indIndex++;
                    trail.indicies[indIndex] = pointIndex + 1;
                    indIndex++;
                    trail.indicies[indIndex] = pointIndex;
                }

                indIndex++;
            }

            int finalIndex = trail.indicies[indIndex - 1];
            for (int i = indIndex; i < trail.indicies.Length; i++)
            {
                trail.indicies[i] = finalIndex;
            }

            trail.Mesh.vertices = trail.verticies;
            trail.Mesh.SetIndices(trail.indicies, MeshTopology.Triangles, 0);
            trail.Mesh.uv = trail.uvs;
            trail.Mesh.normals = trail.normals;
            trail.Mesh.colors = trail.colors;
        }

        private void UpdatePoints(PCTrail line, float deltaTime)
        {
            for (int i = 0; i < line.Points.Count; i++)
            {
                line.Points[i].Update(_noDecay ? 0 : deltaTime);
            }
        }

        private void CheckEmitChange()
        {
            if (_emit != Emit)
            {
                _emit = Emit;
                if (_emit)
                {
                    _activeTrail = new PCTrail(GetMaxNumberOfPoints());
                    _activeTrail.IsActiveTrail = true;

                    OnStartEmit();
                }
                else
                {
                    OnStopEmit();
                    _activeTrail.IsActiveTrail = false;
                    _activeTrail = null;
                }
            }
        }

        private int NumberOfActivePoints(PCTrail line)
        {
            int count = 0;
            for (int index = 0; index < line.Points.Count; index++)
            {
                if (line.Points[index].TimeActive() < TrailData.Lifetime) count++;
            }
            return count;
        }

        [UnityEngine.ContextMenu("Toggle inspector size input method")]
        protected void ToggleSizeInputStyle()
        {
            TrailData.UsingSimpleSize = !TrailData.UsingSimpleSize;
        }
        [UnityEngine.ContextMenu("Toggle inspector color input method")]
        protected void ToggleColorInputStyle()
        {
            TrailData.UsingSimpleColor = !TrailData.UsingSimpleColor;
        }

        public void LifeDecayEnabled(bool enabled)
        {
            _noDecay = !enabled;
        }

        /// <summary>
        /// Translates every point in the vector t
        /// </summary>
        public void Translate(Vector3 t)
        {
            if (_activeTrail != null)
            {
                for (int i = 0; i < _activeTrail.Points.Count; i++)
                {
                    _activeTrail.Points[i].Position += t;
                }
            }

            OnTranslate(t);
        }

        /// <summary>
        /// Insert a trail into this trail renderer. 
        /// </summary>
        /// <param name="from">The start position of the trail.</param>
        /// <param name="to">The end position of the trail.</param>
        /// <param name="distanceBetweenPoints">Distance between each point on the trail</param>
        public void CreateTrail(Vector3 from, Vector3 to, float distanceBetweenPoints)
        {
            float distanceBetween = Vector3.Distance(from, to);

            Vector3 dirVector = to - from;
            dirVector = dirVector.normalized;

            float currentLength = 0;

            CircularBuffer<PCTrailPoint> newLine = new CircularBuffer<PCTrailPoint>(GetMaxNumberOfPoints());
            int pointNumber = 0;
            while (currentLength < distanceBetween)
            {
                PCTrailPoint newPoint = new PCTrailPoint();
                newPoint.PointNumber = pointNumber;
                newPoint.Position = from + dirVector * currentLength;
                newLine.Add(newPoint);
                InitialiseNewPoint(newPoint);

                pointNumber++;

                if (distanceBetweenPoints <= 0)
                    break;
                else
                    currentLength += distanceBetweenPoints;
            }

            PCTrailPoint lastPoint = new PCTrailPoint();
            lastPoint.PointNumber = pointNumber;
            lastPoint.Position = to;
            newLine.Add(lastPoint);
            InitialiseNewPoint(lastPoint);

            PCTrail newTrail = new PCTrail(GetMaxNumberOfPoints());
            newTrail.Points = newLine;
            
        }

        /// <summary>
        /// Clears all active trails from the system.
        /// </summary>
        /// <param name="emitState">Desired emit state after clearing</param>
        public void ClearSystem(bool emitState)
        {
            if (_activeTrail != null)
            {
                _activeTrail.Dispose();
                _activeTrail = null;
            }

            Emit = emitState;
            _emit = !emitState;

            CheckEmitChange();
        }

        /// <summary>
        /// Get the number of active seperate trail segments.
        /// </summary>
        public int NumSegments()
        {
            int num = 0;
            if (_activeTrail != null && NumberOfActivePoints(_activeTrail) != 0)
                num++;
            return num;
        }
    }

    public class CsTrailRenderer : MonoBehaviour
    {
        public PCTrailRendererData Data;
        public Material TrailMat;
        private List<PCTrail> mNeedRenderTrails = new List<PCTrail>();
        private int GlobalTrailRendererCount = 0;
        private List<PCTrailObj> mTrailObjs = new List<PCTrailObj>();
        private List<PCTrailObj> mNeedDeleteObjs = new List<PCTrailObj>();
        private Mesh mMesh;

        void Awake()
        {
            GameSetting.instance.NoticeSaveOptions += NoticeSaveOptions;
            CheckQualityLevel();
        }

        public PCTrailObj CreateTrailObj(Vector3 pos,Vector3 dir,bool long_trail = true)
        {
            GlobalTrailRendererCount++;
            
            PCTrailObj obj = new PCTrailObj(this);
            //if (!long_trail)
            //{
            //    obj.MaxNumberOfPoints = 10;
            //    obj.DelayLifeTimeUnitTime = 0.5f;
            //}
            obj.Awake(pos,dir,Data);
            mTrailObjs.Add(obj);
            return obj;
        }

        public void DestroyTrailObj(PCTrailObj obj)
        {
            if(obj == null)
                return;
            obj.Destroy();
            mTrailObjs.Remove(obj);            
            //mNeedDeleteObjs.Add(obj);
        }

        private void UpdateDeleteTrailObj(float dt)
        {
            if(mNeedDeleteObjs.Count == 0)
                return;
            for(int i = 0;i<mNeedDeleteObjs.Count;)
            {
                if(mNeedDeleteObjs[i].DestroyTime <= 0)
                {
                    mNeedDeleteObjs[i].Destroy();
                    GlobalTrailRendererCount --;
                    if(GlobalTrailRendererCount == 0)
                    {
                        ClearMesh();
                        mNeedRenderTrails.Clear();
                    }
                    mNeedDeleteObjs.RemoveAt(i);
                    
                }
                else
                {
                    mNeedDeleteObjs[i].DestroyTime -= Time.deltaTime;
                    mNeedDeleteObjs[i].Update();
                    i++;
                }

            }
        }

        public void PushRenderQueue(PCTrail trail)
        {
            mNeedRenderTrails.Add(trail);
        }

        private void DrawMesh(Mesh trailMesh, Material trailMaterial)
        {
            Graphics.DrawMesh(trailMesh, Matrix4x4.identity, trailMaterial, gameObject.layer);
        }

        private void ClearMesh()
        {
            if(mMesh == null)
            {
                mMesh = new Mesh();
                mMesh.MarkDynamic();
            }
                
            else
                mMesh.Clear(false);
        }

        void UpdateRenderQueue()
        {
            ClearMesh();
            if (mNeedRenderTrails.Count == 0 || TrailMat == null)
            {
                return;
            }
            CombineInstance[] combineInstances = new CombineInstance[mNeedRenderTrails.Count];
            for (int i = 0; i < mNeedRenderTrails.Count; i++)
            {
                combineInstances[i] = new CombineInstance
                {
                    mesh = mNeedRenderTrails[i].Mesh,
                    subMeshIndex = 0,
                    transform = Matrix4x4.identity
                };
            }
            mMesh.CombineMeshes(combineInstances, true, false);
            DrawMesh(mMesh, TrailMat);
            mNeedRenderTrails.Clear();
        }
        
        void Update()
        {
            UpdateDeleteTrailObj(Time.deltaTime);
        }

        void LateUpdate()
        {
            UpdateRenderQueue();
        }

        void OnDestroy()
        {
            for(int i = 0,imax = mTrailObjs.Count;i<imax;i++)
            {
                mTrailObjs[i].Destroy();
            }
            mTrailObjs.Clear();
            mNeedRenderTrails.Clear();
            ClearMesh();
            GameSetting.instance.NoticeSaveOptions -= NoticeSaveOptions;
        }

        void NoticeSaveOptions()
        {
            CheckQualityLevel();
        }

        bool CheckQualityLevel()
        {
            bool enable = GameSetting.instance.option.mQualityLevel >= 1;
            if(enable != this.gameObject.activeSelf)
                this.gameObject.SetActive(enable);
            return enable;
        }
    }
}


