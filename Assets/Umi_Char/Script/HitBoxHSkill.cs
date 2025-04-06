using UnityEngine;

public class HitboxHSkill : MonoBehaviour
{
    public float rulerBladeDamage = 20f;   // ✅ ดาเมจของ RulerBlade
    public float greatSwordDamage = 30f;   // ✅ ดาเมจของ GreatSword

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
        PlayerController player = PlayerController.instance;
        if (player != null)
        {
            GreatSwordFighter greatSwordFighter = player.GetComponent<GreatSwordFighter>();
            int chargeLevel = (greatSwordFighter != null) ? greatSwordFighter.chargeLevel : 0; // ✅ ถ้าไม่มี ให้เป็น 0

            float baseDamage = player.isGreatSwordMode ? greatSwordDamage : rulerBladeDamage;

            // ✅ เพิ่มตัวคูณเฉพาะเมื่อ chargeLevel > 0
            float chargeMultiplier = (chargeLevel > 0) ? 1f + (chargeLevel * 0.5f) : 1f; 

            float finalDamage = baseDamage * chargeMultiplier;

            Debug.Log($"Hit! Base Damage: {baseDamage}, Charge Level: {chargeLevel}, Final Damage: {finalDamage}");

            return finalDamage;
        }
        return rulerBladeDamage;
    }
}

