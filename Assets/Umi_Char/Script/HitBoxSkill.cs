using UnityEngine;

public class HitboxSkill : MonoBehaviour
{
    public float damage = 100f;  // ค่าดาเมจจาก Dash

    private ThirdPersonDash dashScript;

    void Start()
    {
        // หา ThirdPersonDash script จาก object ตัวละคร
        dashScript = GetComponentInParent<ThirdPersonDash>();
    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.CompareTag("Enemy"))
        {
            Enemy enemy = other.GetComponent<Enemy>();
            if (enemy != null)
            {
                enemy.TakeDamage(damage);  // ทำดาเมจให้กับศัตรู

                // ถ้าศัตรูตาย รีเซ็ตคูลดาวน์ Dash
                if (enemy.health <= 0)
                {
                    dashScript.ResetDashCooldown();
                }
            }
        }
    }
}
