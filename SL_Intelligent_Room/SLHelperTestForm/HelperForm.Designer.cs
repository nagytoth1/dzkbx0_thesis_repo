﻿namespace SLHelperTestForm
{
    partial class HelperForm
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            this.components = new System.ComponentModel.Container();
            this.label1 = new System.Windows.Forms.Label();
            this.label2 = new System.Windows.Forms.Label();
            this.listBox1 = new System.Windows.Forms.ListBox();
            this.btnOpen = new System.Windows.Forms.Button();
            this.btnFelmeres = new System.Windows.Forms.Button();
            this.btnKek = new System.Windows.Forms.Button();
            this.btnUres = new System.Windows.Forms.Button();
            this.kimentBtn = new System.Windows.Forms.Button();
            this.betoltBtn = new System.Windows.Forms.Button();
            this.turnTimer = new System.Windows.Forms.Timer(this.components);
            this.button2Utem = new System.Windows.Forms.Button();
            this.turnTimerKeteszkoz = new System.Windows.Forms.Timer(this.components);
            this.btnLejatszas = new System.Windows.Forms.Button();
            this.btnLampaPiros = new System.Windows.Forms.Button();
            this.btnLampaZold = new System.Windows.Forms.Button();
            this.SuspendLayout();
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(426, 22);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(51, 20);
            this.label1.TabIndex = 0;
            this.label1.Text = "label1";
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.Location = new System.Drawing.Point(426, 58);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(51, 20);
            this.label2.TabIndex = 1;
            this.label2.Text = "label2";
            // 
            // listBox1
            // 
            this.listBox1.FormattingEnabled = true;
            this.listBox1.ItemHeight = 20;
            this.listBox1.Location = new System.Drawing.Point(16, 22);
            this.listBox1.Name = "listBox1";
            this.listBox1.Size = new System.Drawing.Size(382, 104);
            this.listBox1.TabIndex = 2;
            // 
            // btnOpen
            // 
            this.btnOpen.Font = new System.Drawing.Font("Consolas", 10F);
            this.btnOpen.Location = new System.Drawing.Point(16, 145);
            this.btnOpen.Name = "btnOpen";
            this.btnOpen.Size = new System.Drawing.Size(181, 82);
            this.btnOpen.TabIndex = 3;
            this.btnOpen.Text = "Open";
            this.btnOpen.UseVisualStyleBackColor = true;
            this.btnOpen.Click += new System.EventHandler(this.btnOpen_Click);
            // 
            // btnFelmeres
            // 
            this.btnFelmeres.Font = new System.Drawing.Font("Consolas", 10F);
            this.btnFelmeres.Location = new System.Drawing.Point(220, 145);
            this.btnFelmeres.Name = "btnFelmeres";
            this.btnFelmeres.Size = new System.Drawing.Size(178, 82);
            this.btnFelmeres.TabIndex = 4;
            this.btnFelmeres.Text = "Felmer";
            this.btnFelmeres.UseVisualStyleBackColor = true;
            this.btnFelmeres.Click += new System.EventHandler(this.btnFelmeres_Click);
            // 
            // btnKek
            // 
            this.btnKek.Font = new System.Drawing.Font("Consolas", 10F);
            this.btnKek.Location = new System.Drawing.Point(407, 251);
            this.btnKek.Name = "btnKek";
            this.btnKek.Size = new System.Drawing.Size(181, 63);
            this.btnKek.TabIndex = 5;
            this.btnKek.Text = "Lámpa kék";
            this.btnKek.UseVisualStyleBackColor = true;
            this.btnKek.Click += new System.EventHandler(this.btnKek_Click);
            // 
            // btnUres
            // 
            this.btnUres.Font = new System.Drawing.Font("Consolas", 10F);
            this.btnUres.Location = new System.Drawing.Point(594, 251);
            this.btnUres.Name = "btnUres";
            this.btnUres.Size = new System.Drawing.Size(181, 63);
            this.btnUres.TabIndex = 5;
            this.btnUres.Text = "Kikapcsol";
            this.btnUres.UseVisualStyleBackColor = true;
            this.btnUres.Click += new System.EventHandler(this.btnUres_Click);
            // 
            // kimentBtn
            // 
            this.kimentBtn.Font = new System.Drawing.Font("Consolas", 10F);
            this.kimentBtn.Location = new System.Drawing.Point(16, 331);
            this.kimentBtn.Name = "kimentBtn";
            this.kimentBtn.Size = new System.Drawing.Size(181, 85);
            this.kimentBtn.TabIndex = 6;
            this.kimentBtn.Text = "Kiment 4 ütemet";
            this.kimentBtn.UseVisualStyleBackColor = true;
            this.kimentBtn.Click += new System.EventHandler(this.kimentBtn_Click);
            // 
            // betoltBtn
            // 
            this.betoltBtn.Font = new System.Drawing.Font("Consolas", 10F);
            this.betoltBtn.Location = new System.Drawing.Point(220, 331);
            this.betoltBtn.Name = "betoltBtn";
            this.betoltBtn.Size = new System.Drawing.Size(181, 85);
            this.betoltBtn.TabIndex = 6;
            this.betoltBtn.Text = "Betölt 4 ütemet";
            this.betoltBtn.UseVisualStyleBackColor = true;
            this.betoltBtn.Click += new System.EventHandler(this.betoltBtn_Click);
            // 
            // button2Utem
            // 
            this.button2Utem.Font = new System.Drawing.Font("Consolas", 10F);
            this.button2Utem.Location = new System.Drawing.Point(416, 331);
            this.button2Utem.Name = "button2Utem";
            this.button2Utem.Size = new System.Drawing.Size(172, 85);
            this.button2Utem.TabIndex = 5;
            this.button2Utem.Text = "4 ütem kiküldése LN";
            this.button2Utem.UseVisualStyleBackColor = true;
            this.button2Utem.Click += new System.EventHandler(this.button2Utem_Click);
            // 
            // turnTimerKeteszkoz
            // 
            this.turnTimerKeteszkoz.Tick += new System.EventHandler(this.turnTimerKeteszkoz_Tick);
            // 
            // btnLejatszas
            // 
            this.btnLejatszas.Font = new System.Drawing.Font("Consolas", 10F);
            this.btnLejatszas.Location = new System.Drawing.Point(113, 434);
            this.btnLejatszas.Name = "btnLejatszas";
            this.btnLejatszas.Size = new System.Drawing.Size(181, 85);
            this.btnLejatszas.TabIndex = 6;
            this.btnLejatszas.Text = "4 ütem lejátszása";
            this.btnLejatszas.UseVisualStyleBackColor = true;
            this.btnLejatszas.MouseClick += new System.Windows.Forms.MouseEventHandler(this.btnLejatszas_MouseClick);
            // 
            // btnLampaPiros
            // 
            this.btnLampaPiros.Font = new System.Drawing.Font("Consolas", 10F);
            this.btnLampaPiros.Location = new System.Drawing.Point(16, 251);
            this.btnLampaPiros.Name = "btnLampaPiros";
            this.btnLampaPiros.Size = new System.Drawing.Size(181, 63);
            this.btnLampaPiros.TabIndex = 7;
            this.btnLampaPiros.Text = "Lámpa piros";
            this.btnLampaPiros.UseVisualStyleBackColor = true;
            this.btnLampaPiros.Click += new System.EventHandler(this.btnLampaPiros_Click);
            // 
            // btnLampaZold
            // 
            this.btnLampaZold.Font = new System.Drawing.Font("Consolas", 10F);
            this.btnLampaZold.Location = new System.Drawing.Point(220, 251);
            this.btnLampaZold.Name = "btnLampaZold";
            this.btnLampaZold.Size = new System.Drawing.Size(181, 63);
            this.btnLampaZold.TabIndex = 8;
            this.btnLampaZold.Text = "Lámpa zöld";
            this.btnLampaZold.UseVisualStyleBackColor = true;
            this.btnLampaZold.Click += new System.EventHandler(this.btnLampaZold_Click);
            // 
            // HelperForm
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(9F, 20F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(811, 546);
            this.Controls.Add(this.btnLampaZold);
            this.Controls.Add(this.btnLampaPiros);
            this.Controls.Add(this.btnLejatszas);
            this.Controls.Add(this.betoltBtn);
            this.Controls.Add(this.kimentBtn);
            this.Controls.Add(this.btnUres);
            this.Controls.Add(this.button2Utem);
            this.Controls.Add(this.btnKek);
            this.Controls.Add(this.btnFelmeres);
            this.Controls.Add(this.btnOpen);
            this.Controls.Add(this.listBox1);
            this.Controls.Add(this.label2);
            this.Controls.Add(this.label1);
            this.Name = "HelperForm";
            this.Text = "DLLTestForm";
            this.Load += new System.EventHandler(this.HelperForm_Load);
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.ListBox listBox1;
        private System.Windows.Forms.Button btnOpen;
        private System.Windows.Forms.Button btnFelmeres;
        private System.Windows.Forms.Button btnKek;
        private System.Windows.Forms.Button btnUres;
        private System.Windows.Forms.Button kimentBtn;
        private System.Windows.Forms.Button betoltBtn;
        private System.Windows.Forms.Timer turnTimer;
        private System.Windows.Forms.Button button2Utem;
        private System.Windows.Forms.Timer turnTimerKeteszkoz;
        private System.Windows.Forms.Button btnLejatszas;
        private System.Windows.Forms.Button btnLampaPiros;
        private System.Windows.Forms.Button btnLampaZold;
    }
}

