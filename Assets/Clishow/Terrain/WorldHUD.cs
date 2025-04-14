using UnityEngine;


public abstract class WorldHUDComponent : MonoBehaviour
{

}

public abstract class WorldHUDWidget : MonoBehaviour
{
    public Vector3 defaultSize = Vector3.one;

    public virtual string text
    {
        get
        {
            return "";
        }

        set
        {
            return;
        }
    }

    public virtual Sprite background
    {
        get
        {
            return null;
        }

        set
        {
            return;
        }
    }

    public virtual int backgroundType
    {
        get
        {
            return -1;
        }

        set
        {
            return;
        }
    }

    public virtual Color color
    {
        get
        {
            return new Color();
        }

        set
        {
            return;
        }
    }

    public virtual Sprite frame
    {
        get
        {
            return null;
        }

        set
        {
            return;
        }
    }

    public virtual int frameType
    {
        get
        {
            return -1;
        }

        set
        {
            return;
        }
    }

    public virtual Sprite icon
    {
        get
        {
            return null;
        }

        set
        {
            return;
        }
    }

    public virtual int iconType
    {
        get
        {
            return -1;
        }

        set
        {
            return;
        }
    }

    public virtual Sprite mask
    {
        get
        {
            return null;
        }

        set
        {
            return;
        }
    }

    public virtual int maskType
    {
        get
        {
            return -1;
        }

        set
        {
            return;
        }
    }

    public virtual int type
    {
        get
        {
            return 0;
        }

        set
        {
            return;
        }
    }

    public virtual float percentage
    {
        get
        {
            return 0;
        }

        set
        {
            return;
        }
    }

    public virtual float width
    {
        get
        {
            return 0;
        }
    }

    public virtual System.Action<long, uint, WorldHUDLabel> updateFunction
    {
        set
        {
            return;
        }
    }

    public virtual uint time
    {
        get
        {
            return 0;
        }

        set
        {
            return;
        }
    }

    public virtual Material material
    {
        set
        {
            return;
        }
    }

    public Vector3 localPosition
    {
        get
        {
            return transform.localPosition;
        }

        set
        {
            transform.localPosition = value;
        }
    }

    public Vector3 localScale
    {
        get
        {
            return this.transform.localScale;
        }

        set
        {
            this.transform.localScale = value;
        }
    }

    public Vector3 forward
    {
        get
        {
            return this.transform.forward;
        }

        set
        {
            this.transform.forward = value;
        }
    }

    public void Show()
    {
        // transform.localScale = defaultSize;
        gameObject.SetActive(true);
    }

    public void Hide()
    {
        // transform.localScale = Vector3.zero;
        gameObject.SetActive(false);
    }

    public virtual void EnableAnimation()
    {
    }

    public virtual void DisableAnimation()
    {
    }
}

public enum WorldHUDType : int
{
    // Subtype
    BASE,
    RESOURCE,
    REBEL_ARMY,
    REBEL_ARMY_TREASURE,
    REBEL_ARMY_BASE,
    ALLIANCE_BUILDING,
    TERRITORY,
    EXPEDITION,
    REBEL_ARMY_FORTRESS,
    OCCUPY,
    GOVERNMENT,
    TURRENT,
    ELITE_REBEL_ARMY,
    MOBA_BASE,

    // Type
    DEFAULT,
    BUILDING,
    LUA_BEHAVIOR,
};

public class WorldHUD : MonoBehaviour
{
    [SerializeField]
    private int _id;
    public int id
    {
        get
        {
            return _id;
        }

        set
        {
            _id = value;
        }
    }

    [SerializeField]
    private WorldHUDType _type;
    public WorldHUDType type
    {
        get
        {
            return _type;
        }
    }

    [SerializeField]
    private WorldHUDWidget[] _widgets;

    public WorldHUDWidget this[int i]
    {
        get
        {
            return _widgets[i];
        }
    }

    public WorldHUDTimer timer
    {
        get
        {
            return transform.GetComponent<WorldHUDTimer>();
        }
    }

    public void Show()
    {
        transform.localScale = Vector3.one;
    }

    public void Hide()
    {
        transform.localScale = Vector3.zero;
    }
}
