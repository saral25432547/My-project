using UnityEngine;

public class UpdateBarrier : MonoBehaviour
{
    public Transform player;
    public Material barrierMaterial;

    void Update()
    {
        if (barrierMaterial != null && player != null)
        {
            barrierMaterial.SetVector("_PlayerPosition", player.position);
        }
    }
}

