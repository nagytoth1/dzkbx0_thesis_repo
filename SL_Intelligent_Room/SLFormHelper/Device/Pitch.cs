﻿namespace SLFormHelper
{

    /// <summary>
    /// Levente hozzáadhatja a lejátszandó hangokat az itt definiált hangmagasságok szerint a hangszóró hanglistájához
    /// anélkül, hogy tudná, hogyan működnek az indexek hangso esetén.
    /// Ez egy intuitívabb, leíróbb módja a hangszórók vezérlésének, valamint nem lehet tartományon kívülre eső indexet megadni.
    /// <br></br>---------------------------------------<br></br>
    /// Levente can add sounds to speaker's soundList - he doesn't have to know how indices work in case of hangso<br></br>
    /// This is a more intuitive way to control speakers and he can't give an index out of range (chance of getting error reduced)
    /// </summary>
    public enum Pitch :byte
    {
        C_OKTAV4,
        H_OKTAV3,
        B_OKTAV3,
        A_OKTAV3,
        GISZ_OKTAV3,
        G_OKTAV3,
        FISZ_OKTAV3,
        F_OKTAV3,
        E_OKTAV3,
        DISZ_OKTAV3,
        D_OKTAV3,
        CISZ_OKTAV3,
        C_OKTAV3,
        H_OKTAV2,
        B_OKTAV2,
        A_OKTAV2,
        GISZ_OKTAV2,
        G_OKTAV2,
        FISZ_OKTAV2,
        F_OKTAV2,
        E_OKTAV2,
        DISZ_OKTAV2,
        D_OKTAV2,
        CISZ_OKTAV2,
        C_OKTAV2,
        H_OKTAV1,
        B_OKTAV1,
        A_OKTAV1,
        GISZ_OKTAV1,
        G_OKTAV1,
        FISZ_OKTAV1,
        F_OKTAV1,
        E_OKTAV1,
        DISZ_OKTAV1,
        D_OKTAV1,
        CISZ_OKTAV1,
        C_OKTAV1,
        H,
        B,
        A,
        GISZ,
        G,
        FISZ,
        F,
        E,
        DISZ,
        D,
        CISZ,
        C,
        SZUNET
    }
}
