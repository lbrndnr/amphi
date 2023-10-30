import unittest
import pdf
from PyPDF2 import PdfReader
from pdfminer.high_level import extract_text
from pdfminer.layout import LAParams

class TestPDF(unittest.TestCase):

    def test_email_extraction(self):
        params = LAParams(detect_vertical=True)
        text = extract_text("res/1905.07844v1.pdf", laparams=params)

        print(text)

        emails = pdf.extract_emails(["Linda Wang", "Alexander Wong"], text)
        self.assertEqual(emails, ["ly8wang@uwaterloo.ca", "a28wong@uwaterloo.ca"])

if __name__ == "__main__":
    unittest.main()