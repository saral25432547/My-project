using UnityEngine;

public class HitboxPlayer : MonoBehaviour
{
    public float rulerBladeDamage = 20f;   // ✅ ดาเมจของ RulerBlade
    public float greatSwordDamage = 35f;   // ✅ ดาเมจของ GreatSword

    private void OnTriggerEnter(Collider other)
    {
        if (other.CompareTag("Enemy"))
        {
            Enemy enemy = other.GetComponent<Enemy>();
            if (enemy != null)
            {
                float damage = GetWeaponDamage(); // ✅ ใช้ดาเมจตามอาวุธที่ถืออยู่
                enemy.TakeDamage(damage);
                Debug.Log("Hit! ดาเมจที่ทำ: " + damage);
            }
        }
    }

    float GetWeaponDamage()
    {
        PlayerController player = PlayerController.instance; // ✅ ดึงค่า PlayerController
        if (player != null)
        {
            return player.isGreatSwordMode ? greatSwordDamage : rulerBladeDamage; // ✅ เลือกดาเมจตามโหมดอาวุธ
        }
        return rulerBladeDamage; // ค่า default ถ้าไม่เจอ player
    }
}
