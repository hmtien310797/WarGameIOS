using UnityEngine;
using System.Collections;

public class CsParticleAutoPlay : MonoBehaviour
{
    public Clishow.CsParticleController particle;

    public void Start()
    {
        if(particle != null)
            particle.Active();
    }
}
