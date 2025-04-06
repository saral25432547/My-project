using UnityEngine;

public class boxdmgCheck : MonoBehaviour
{
    [SerializeField] private Enemy enemy; // ✅ ดึงข้อมูลจาก Enemy

    private void Start()
    {
        if (enemy == null)
        {
            enemy = GetComponentInParent<Enemy>(); // ✅ ดึง Enemy อัตโนมัติถ้าไม่ได้เซ็ตค่า
        }
    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.CompareTag("Player")) // 🎯 ตรวจสอบว่าชน Player
        {
            PlayerController player = other.GetComponent<PlayerController>();
            if (player != null && enemy != null)
            {
                player.TakeDamage(enemy.damage); // ✅ ส่ง damage ของ Enemy ไปยัง Player
            }
        }
    }
}
