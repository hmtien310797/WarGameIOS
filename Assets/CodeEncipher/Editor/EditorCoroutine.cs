using System.Collections;
using UnityEditor;

namespace J3Tech
{
    public class EditorCoroutine
    {
        public static EditorCoroutine Start(IEnumerator _routine)
        {
            EditorCoroutine coroutine = new EditorCoroutine(_routine);
            coroutine.Start();
            return coroutine;
        }
        readonly IEnumerator _routine;
        EditorCoroutine(IEnumerator routine)
        {
            _routine = routine;
        }
        void Start()
        {
            EditorApplication.update += Update;
        }
        public void Stop()
        {
            EditorApplication.update -= Update;
        }
        void Update()
        {
            if (!_routine.MoveNext())
            {
                Stop();
            }
        }
    }
}
