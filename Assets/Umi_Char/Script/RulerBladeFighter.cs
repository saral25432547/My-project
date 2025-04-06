using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RulerBladeFighter : MonoBehaviour
{
    private Animator animator;
    private PlayerController playerController; // ✅ อ้างอิงไปที่ PlayerController

    public float cooldownTime = 2f;
    private float nextFireTime = 0f;
    public static int noOfClicks = 0;
    float lastClickedTime = 0;
    float maxComboDelay = 1;

    public GameObject[] slashEffects; // เก็บเอฟเฟคหลายแบบ
    public GameObject[] hitboxSlashes; // ✅ เพิ่ม hitbox แต่ละคอมโบ

    [SerializeField] private AudioSource hit1Sound; // 🔊 ประกาศตัวแปรเสียงสำหรับ hit1
    
    private void Start()
    {
        animator = GetComponentInChildren<Animator>(); // ดึง Animator ของตัวละคร
        playerController = GetComponent<PlayerController>(); // ✅ ดึง PlayerController
    }

    void Update()
    {
        // ✅ ใช้โค้ดนี้ต่อเมื่อ "อยู่ในโหมด Ruler Blade" และ "ไม่ได้อยู่ในโหมด Great Sword"
        if (playerController == null || !playerController.RulerBlade || playerController.isGreatSwordMode) 
        {
            return;
        }

        // ✅ ห้ามกดโจมตีถ้ากำลังเปลี่ยนอาวุธอยู่
        if (animator.GetCurrentAnimatorStateInfo(0).IsName("ChangetoGreatSword")) 
        {
            return;
        }

        // ✅ ทำงานเฉพาะเมื่ออยู่ใน Ruler Blade และไม่ได้ใช้ Great Sword
        if (animator.GetCurrentAnimatorStateInfo(0).normalizedTime > 0.7f && animator.GetCurrentAnimatorStateInfo(0).IsName("FirstComboN"))
        {
            animator.SetBool("hit1", false);
        }
        if (animator.GetCurrentAnimatorStateInfo(0).normalizedTime > 0.7f && animator.GetCurrentAnimatorStateInfo(0).IsName("SecondCombo"))
        {
            animator.SetBool("hit2", false);
        }
        if (animator.GetCurrentAnimatorStateInfo(0).normalizedTime > 0.7f && animator.GetCurrentAnimatorStateInfo(0).IsName("ThirdComboN"))
        {
            animator.SetBool("hit3", false);
            noOfClicks = 0;
        }

        if (Time.time - lastClickedTime > maxComboDelay)
        {
            noOfClicks = 0;
        }

        // ✅ cooldown time
        if (Time.time > nextFireTime)
        {
            // ✅ Check for mouse input
            if (Input.GetMouseButtonDown(0))
            {
                OnClick();
            }
        }
    }

    void ShowSlashEffect(int hitIndex)
    {
        if (slashEffects.Length == 0 || hitboxSlashes.Length == 0) return;

        int effectIndex = Mathf.Clamp(hitIndex, 0, slashEffects.Length - 1);
        int hitboxIndex = Mathf.Clamp(hitIndex, 0, hitboxSlashes.Length - 1);

        GameObject effect = slashEffects[effectIndex];
        GameObject hitbox = hitboxSlashes[hitboxIndex]; // ✅ ใช้ hitbox ของคอมโบนี้

        effect.SetActive(true);
        hitbox.SetActive(true); // ✅ เปิดใช้งาน Hitbox พร้อมกับ Slash Effect

        // ปิดเอฟเฟค & hitbox หลังจากเล่นเสร็จ
        StartCoroutine(HideEffectAfterTime(effect, 0.5f));
        StartCoroutine(HideEffectAfterTime(hitbox, 0.2f)); // ✅ ปิด Hitbox เร็วกว่าหน่อย
    }

    IEnumerator HideEffectAfterTime(GameObject obj, float delay)
    {
        yield return new WaitForSeconds(delay);
        obj.SetActive(false);
    }

    void OnClick()
    {
        lastClickedTime = Time.time;
        noOfClicks++;

        if (noOfClicks == 1)
        {
            animator.SetBool("hit1", true);
            // 🎮 เล่นเสียงโจมตีแรก
            if (hit1Sound != null)
            {
                hit1Sound.Play();
            }
            Invoke("ShowSlashEffect_0", 0.5f); // ✅ แสดง Slash Effect 0 หลังจาก 0.5 วินาที
        }
        noOfClicks = Mathf.Clamp(noOfClicks, 0, 3);

        if (noOfClicks >= 2 && animator.GetCurrentAnimatorStateInfo(0).normalizedTime > 0.7f && animator.GetCurrentAnimatorStateInfo(0).IsName("FirstComboN"))
        {
            animator.SetBool("hit1", false);
            animator.SetBool("hit2", true);
            Invoke("ShowSlashEffect_1", 0.5f); // ✅ แสดง Slash Effect 1 หลังจาก 0.5 วินาที
        }
        if (noOfClicks >= 3 && animator.GetCurrentAnimatorStateInfo(0).normalizedTime > 0.7f && animator.GetCurrentAnimatorStateInfo(0).IsName("SecondCombo"))
        {
            animator.SetBool("hit2", false);
            animator.SetBool("hit3", true);
            Invoke("ShowSlashEffect_2", 0.5f); // ✅ แสดง Slash Effect 2 หลังจาก 0.5 วินาที
        }
    }

    // ✅ ฟังก์ชันสำหรับเรียกใช้ Effect แยกตามลำดับ
    void ShowSlashEffect_0() { ShowSlashEffect(0); }
    void ShowSlashEffect_1() { ShowSlashEffect(1); }
    void ShowSlashEffect_2() { ShowSlashEffect(2); }
}
