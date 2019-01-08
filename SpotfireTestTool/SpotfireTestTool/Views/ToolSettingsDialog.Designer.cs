namespace Com.PerkinElmer.Service.SpotfireTestTool.Views
{
    partial class ToolSettingsDialog
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
            this.groupBox1 = new System.Windows.Forms.GroupBox();
            this.markingComboBox = new System.Windows.Forms.ComboBox();
            this.groupBox2 = new System.Windows.Forms.GroupBox();
            this.markingRadio = new System.Windows.Forms.RadioButton();
            this.allRecordRadio = new System.Windows.Forms.RadioButton();
            this.groupBox3 = new System.Windows.Forms.GroupBox();
            this.dataTableComboBox = new System.Windows.Forms.ComboBox();
            this.cancelButton = new System.Windows.Forms.Button();
            this.okButton = new System.Windows.Forms.Button();
            this.groupBox1.SuspendLayout();
            this.groupBox2.SuspendLayout();
            this.groupBox3.SuspendLayout();
            this.SuspendLayout();
            // 
            // groupBox1
            // 
            this.groupBox1.Controls.Add(this.markingComboBox);
            this.groupBox1.Dock = System.Windows.Forms.DockStyle.Top;
            this.groupBox1.Location = new System.Drawing.Point(5, 125);
            this.groupBox1.Name = "groupBox1";
            this.groupBox1.Size = new System.Drawing.Size(316, 55);
            this.groupBox1.TabIndex = 3;
            this.groupBox1.TabStop = false;
            this.groupBox1.Text = "Marking";
            // 
            // markingComboBox
            // 
            this.markingComboBox.Dock = System.Windows.Forms.DockStyle.Fill;
            this.markingComboBox.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.markingComboBox.Enabled = false;
            this.markingComboBox.FormattingEnabled = true;
            this.markingComboBox.Location = new System.Drawing.Point(3, 16);
            this.markingComboBox.Name = "markingComboBox";
            this.markingComboBox.Size = new System.Drawing.Size(310, 21);
            this.markingComboBox.TabIndex = 0;
            // 
            // groupBox2
            // 
            this.groupBox2.Controls.Add(this.markingRadio);
            this.groupBox2.Controls.Add(this.allRecordRadio);
            this.groupBox2.Dock = System.Windows.Forms.DockStyle.Top;
            this.groupBox2.Location = new System.Drawing.Point(5, 56);
            this.groupBox2.Name = "groupBox2";
            this.groupBox2.Size = new System.Drawing.Size(316, 69);
            this.groupBox2.TabIndex = 4;
            this.groupBox2.TabStop = false;
            this.groupBox2.Text = "Data Range";
            // 
            // markingRadio
            // 
            this.markingRadio.AutoSize = true;
            this.markingRadio.Location = new System.Drawing.Point(6, 43);
            this.markingRadio.Name = "markingRadio";
            this.markingRadio.Size = new System.Drawing.Size(98, 17);
            this.markingRadio.TabIndex = 1;
            this.markingRadio.Text = "marked records";
            this.markingRadio.UseVisualStyleBackColor = true;
            this.markingRadio.CheckedChanged += new System.EventHandler(this.markingRadio_CheckedChanged);
            // 
            // allRecordRadio
            // 
            this.allRecordRadio.AutoSize = true;
            this.allRecordRadio.Checked = true;
            this.allRecordRadio.Location = new System.Drawing.Point(7, 20);
            this.allRecordRadio.Name = "allRecordRadio";
            this.allRecordRadio.Size = new System.Drawing.Size(73, 17);
            this.allRecordRadio.TabIndex = 0;
            this.allRecordRadio.TabStop = true;
            this.allRecordRadio.Text = "all records";
            this.allRecordRadio.UseVisualStyleBackColor = true;
            // 
            // groupBox3
            // 
            this.groupBox3.Controls.Add(this.dataTableComboBox);
            this.groupBox3.Dock = System.Windows.Forms.DockStyle.Top;
            this.groupBox3.Location = new System.Drawing.Point(5, 5);
            this.groupBox3.Name = "groupBox3";
            this.groupBox3.Size = new System.Drawing.Size(316, 51);
            this.groupBox3.TabIndex = 5;
            this.groupBox3.TabStop = false;
            this.groupBox3.Text = "Data table";
            // 
            // dataTableComboBox
            // 
            this.dataTableComboBox.Dock = System.Windows.Forms.DockStyle.Fill;
            this.dataTableComboBox.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.dataTableComboBox.FormattingEnabled = true;
            this.dataTableComboBox.Location = new System.Drawing.Point(3, 16);
            this.dataTableComboBox.Name = "dataTableComboBox";
            this.dataTableComboBox.Size = new System.Drawing.Size(310, 21);
            this.dataTableComboBox.TabIndex = 0;
            // 
            // cancelButton
            // 
            this.cancelButton.DialogResult = System.Windows.Forms.DialogResult.Cancel;
            this.cancelButton.Location = new System.Drawing.Point(165, 186);
            this.cancelButton.Name = "cancelButton";
            this.cancelButton.Size = new System.Drawing.Size(75, 23);
            this.cancelButton.TabIndex = 5;
            this.cancelButton.Text = "Cancel";
            this.cancelButton.UseVisualStyleBackColor = true;
            // 
            // okButton
            // 
            this.okButton.Location = new System.Drawing.Point(246, 186);
            this.okButton.Name = "okButton";
            this.okButton.Size = new System.Drawing.Size(75, 23);
            this.okButton.TabIndex = 4;
            this.okButton.Text = "OK";
            this.okButton.UseVisualStyleBackColor = true;
            this.okButton.Click += new System.EventHandler(this.okButton_Click);
            // 
            // ToolSettingsDialog
            // 
            this.AcceptButton = this.okButton;
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.CancelButton = this.cancelButton;
            this.ClientSize = new System.Drawing.Size(326, 217);
            this.Controls.Add(this.cancelButton);
            this.Controls.Add(this.groupBox1);
            this.Controls.Add(this.okButton);
            this.Controls.Add(this.groupBox2);
            this.Controls.Add(this.groupBox3);
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedDialog;
            this.MaximizeBox = false;
            this.MinimizeBox = false;
            this.Name = "ToolSettingsDialog";
            this.Padding = new System.Windows.Forms.Padding(5);
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
            this.Text = " Select Data Range";
            this.Load += new System.EventHandler(this.ToolSettingsDialog_Load);
            this.groupBox1.ResumeLayout(false);
            this.groupBox2.ResumeLayout(false);
            this.groupBox2.PerformLayout();
            this.groupBox3.ResumeLayout(false);
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.GroupBox groupBox1;
        private System.Windows.Forms.ComboBox markingComboBox;
        private System.Windows.Forms.GroupBox groupBox2;
        private System.Windows.Forms.RadioButton markingRadio;
        private System.Windows.Forms.RadioButton allRecordRadio;
        private System.Windows.Forms.GroupBox groupBox3;
        private System.Windows.Forms.ComboBox dataTableComboBox;
        private System.Windows.Forms.Button cancelButton;
        private System.Windows.Forms.Button okButton;
    }
}