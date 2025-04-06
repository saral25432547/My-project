using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraScript : MonoBehaviour
{
    [SerializeField] private float mouseSensivity = 5f;
    private float rotationY;
    private float rotationX;

    [SerializeField] private Transform target;
    [SerializeField] private float distanceFromTarget = 5f;
    [SerializeField] private float zoomSpeed = 2f;
    [SerializeField] private float zoomMin = 2f;
    [SerializeField] private float zoomMax = 10f;

    private Vector3 currentRotation;
    private Vector3 smoothVelocity = Vector3.zero;
    [SerializeField] private float smoothTime = 0.2f;
    [SerializeField] private Vector2 rotationXMinMax = new Vector2(-20, 40);

    void Update()
    {
        // รับค่าการหมุนกล้องจากเมาส์
        float mouseX = Input.GetAxis("Mouse X") * mouseSensivity;
        float mouseY = Input.GetAxis("Mouse Y") * mouseSensivity;

        rotationY += mouseX;
        rotationX += mouseY;
        rotationX = Mathf.Clamp(rotationX, rotationXMinMax.x, rotationXMinMax.y);
        Vector3 nextRotation = new Vector3(rotationX, rotationY);

        currentRotation = Vector3.SmoothDamp(currentRotation, nextRotation, ref smoothVelocity, smoothTime);
        transform.localEulerAngles = currentRotation;

        // ✅ เพิ่มระบบซูมเข้า-ออกด้วยลูกล้อเมาส์
        float scrollInput = Input.GetAxis("Mouse ScrollWheel");
        distanceFromTarget -= scrollInput * zoomSpeed;
        distanceFromTarget = Mathf.Clamp(distanceFromTarget, zoomMin, zoomMax);

        // อัปเดตตำแหน่งของกล้อง
        transform.position = target.position - transform.forward * distanceFromTarget;

        // ✅ กด ALT เพื่อล็อคการหมุนกล้อง
        if (Input.GetKey(KeyCode.LeftAlt))
        {
            mouseSensivity = 0;
        }
        else
        {
            mouseSensivity = 3;
        }
    }
}
