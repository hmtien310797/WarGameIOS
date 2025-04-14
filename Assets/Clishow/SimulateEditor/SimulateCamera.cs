using UnityEngine;
using System.Collections;

namespace Clishow
{
#if UNITY_EDITOR
    public class SimulateCamera : MonoBehaviour
    {
        private float m_deltX = 0f;
        private float m_deltY = 0f;
        private float m_distance = 10f;
        private float m_mSpeed = 5f;
        private Vector3 m_mouseMovePos = Vector3.zero;

        void Start()
        {
            Camera.main.transform.localPosition = new Vector3(0, m_distance, 0);
            m_deltX += Input.GetAxis("Mouse X") * m_mSpeed;
            m_deltY -= Input.GetAxis("Mouse Y") * m_mSpeed;
            m_deltX = ClampAngle(m_deltX, -360, 360);
            m_deltY = ClampAngle(m_deltY, -90, 90);
            Camera.main.transform.rotation = Quaternion.Euler(m_deltY, m_deltX, 0);
        }

        void Update()
        {
            if (Input.GetMouseButton(1))
            {
                m_deltX += Input.GetAxis("Mouse X") * m_mSpeed;
                m_deltY -= Input.GetAxis("Mouse Y") * m_mSpeed;
                m_deltX = ClampAngle(m_deltX, -360, 360);
                m_deltY = ClampAngle(m_deltY, -90, 90);
                Camera.main.transform.rotation = Quaternion.Euler(m_deltY, m_deltX, 0);
            }
            
            if (Input.GetAxis("Mouse ScrollWheel") != 0)
            {
                m_distance = Input.GetAxis("Mouse ScrollWheel") * 10f;
                Camera.main.transform.localPosition = Camera.main.transform.position + Camera.main.transform.forward * m_distance;
            }

            if (Input.GetMouseButtonDown(2))
            {
                Ray ray = Camera.main.ScreenPointToRay(Input.mousePosition);
                RaycastHit hitInfo;
                if (Physics.Raycast(ray, out hitInfo))
                {
                    m_mouseMovePos = hitInfo.point;
                }
            }
            else if (Input.GetMouseButton(2))
            {
                Vector3 p = Vector3.zero;
                Ray ray = Camera.main.ScreenPointToRay(Input.mousePosition);
                RaycastHit hitInfo;
                if (Physics.Raycast(ray, out hitInfo))
                {
                    p = hitInfo.point - m_mouseMovePos;
                    p.y = 0f;
                }
                Camera.main.transform.localPosition = Camera.main.transform.position - p * 0.05f; 
            }
            
            if (Input.GetKey(KeyCode.Space))
            {
                m_distance = 10.0f;
                Camera.main.transform.localPosition = new Vector3(0, m_distance, 0);
            }
        }
        
        float ClampAngle(float angle, float minAngle, float maxAgnle)
        {
            if (angle <= -360)
                angle += 360;
            if (angle >= 360)
                angle -= 360;

            return Mathf.Clamp(angle, minAngle, maxAgnle);
        }
    }
#endif
}

