using UnityEngine;

[System.Serializable]
public class DropItem
{
    public GameObject itemPrefab;  // Prefab ไอเทม
    [Range(0f, 100f)]
    public float dropChance;  // โอกาสดรอป (%)
}

public class DropSystem : MonoBehaviour
{
    public DropItem[] dropItems;  // ✅ อาเรย์ของไอเทมที่สามารถดรอป

    public void DropLoot(Vector3 dropPosition)
    {
        foreach (DropItem drop in dropItems)
        {
            if (Random.value * 100f <= drop.dropChance) // ✅ เช็คโอกาสดรอปของไอเทมแต่ละชิ้น
            {
                Instantiate(drop.itemPrefab, dropPosition, Quaternion.identity);
                Debug.Log("🎁 ดรอปไอเทม: " + drop.itemPrefab.name);
            }
        }
    }
}
