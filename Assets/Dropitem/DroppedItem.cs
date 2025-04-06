using UnityEngine;

public class DroppedItem : MonoBehaviour
{
    public enum ItemType { HealthPotion, SpeedBoost, AttackBoost } // ✅ ประเภทของไอเทม
    public ItemType itemType;
    public float effectValue = 20f;  // ค่าของเอฟเฟค (เช่น +20 HP, +20% Speed)
    public float effectDuration = 5f; // ระยะเวลาของเอฟเฟค (เช่น SpeedBoost 5 วิ)

    private void OnTriggerEnter(Collider other)
    {
        if (other.CompareTag("Player")) // ✅ เช็คว่าชนกับผู้เล่น
        {
            PlayerController player = other.GetComponent<PlayerController>();

            if (player != null)
            {
                ApplyEffect(player); // 🎯 เรียกใช้ฟังก์ชันเพื่อให้เอฟเฟคกับผู้เล่น
                Destroy(gameObject); // 💥 ทำลายไอเทมหลังจากเก็บไปแล้ว
            }
        }
    }

    void ApplyEffect(PlayerController player)
    {
        switch (itemType)
        {
            case ItemType.HealthPotion:
                player.Heal(effectValue);
                Debug.Log("💚 เพิ่มพลังชีวิต " + effectValue);
                break;
            
            case ItemType.SpeedBoost:
            player.StartCoroutine(player.SpeedBoost(effectValue, effectDuration));
            
            // ✅ รีเซ็ตคูลดาวน์ Dash ทันที
            ThirdPersonDash dashScript = player.GetComponent<ThirdPersonDash>();
            if (dashScript != null)
            {
                dashScript.ResetDashCooldown();
            }

            Debug.Log("⚡ เพิ่มความเร็ว " + effectValue + "% และรีเซ็ต Dash คูลดาวน์ทันที!");
            break;

            case ItemType.AttackBoost:
                player.StartCoroutine(player.AttackBoost(effectValue, effectDuration));
                Debug.Log("🔥 เพิ่มพลังโจมตี " + effectValue + "% เป็นเวลา " + effectDuration + " วินาที");
                break;
        }
    }
}
