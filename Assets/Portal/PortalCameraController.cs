using UnityEngine;

public class PortalCameraController : MonoBehaviour
{
    public Camera playerCamera;   // กล้องของผู้เล่น
    public Transform portal;      // พอร์ทัลฝั่งต้นทาง
    public Transform targetPortal;// พอร์ทัลฝั่งปลายทาง
    private Camera portalCam;     // กล้องของพอร์ทัล

    void Start()
    {
        portalCam = GetComponent<Camera>(); // ดึง Camera Component ของ PortalCamera
    }

    void LateUpdate()
    {
        if (playerCamera == null || portal == null || targetPortal == null)
            return;

        // คำนวณการหมุนของ Portal Camera ที่จะต้องสัมพันธ์กับ Player Camera
        Quaternion difference = Quaternion.Inverse(portal.rotation) * playerCamera.transform.rotation;
        Quaternion targetRotation = targetPortal.rotation * difference;

        // ปรับการหมุนของ Portal Camera ให้ตรงกับการหมุนของ Player Camera
        transform.rotation = targetRotation;

        // ตั้งค่า Projection Matrix ให้เหมือนกับ Player Camera
        portalCam.projectionMatrix = playerCamera.projectionMatrix;
    }
}
