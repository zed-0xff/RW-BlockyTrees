using HarmonyLib;
using RimWorld;
using Verse;

namespace Blocky.Trees;

[StaticConstructorOnStartup]
public class Init
{
    static Init()
    {
        Harmony harmony = new Harmony("Blocky.Trees");
        harmony.PatchAll();
    }
}
