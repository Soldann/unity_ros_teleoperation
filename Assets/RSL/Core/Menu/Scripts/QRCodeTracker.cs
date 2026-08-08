using UnityEngine;
using Meta.XR.MRUtilityKit;
using Unity.XR.CoreUtils;

namespace RSL.Core.Menu
{
public class QRCodeTracker : MonoBehaviour
{

    public GameObject _prefab;

    public MRUKTrackable trackable;

    public XROrigin xrOrigin;

    public void OnTrackableAdded(MRUKTrackable trackable)
    {

        Debug.Log($"Trackable of type {trackable.TrackableType} added.");
        var go = Instantiate(_prefab);
        
        var follower = go.AddComponent<QRFollower>();
        follower.trackable = trackable;
        follower.xrOrigin = xrOrigin; // your recentering origin
    }

    public void OnTrackableRemoved(MRUKTrackable trackable)
    {
        Debug.Log($"Trackable removed: {trackable.name}");
        Destroy(trackable.gameObject);
    }
}
}
