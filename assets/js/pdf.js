import * as pdfjsLib from 'pdfjs-dist';
import * as pdfjsWorker from 'pdfjs-dist/build/pdf.worker'; // bundles pdf.worker correctly
import * as pdfjsViewer from 'pdfjs-dist/web/pdf_viewer';

pdfjsLib.GlobalWorkerOptions.workerSrc = '../assets/pdf.worker.js'

window.onload = async () => {
	const container = document.querySelector('#pdf-wrapper');
	if (container == null) {
		return
	}

	const url = container.getAttribute("pdf_url");
	const pdf = await pdfjsLib.getDocument(url).promise;

	// Load information from the first page.
	const page = await pdf.getPage(1);
	const eventBus = new pdfjsViewer.EventBus();
	const linkService = new pdfjsViewer.PDFLinkService({
		eventBus,
	});

	const params = {
		scale: window.devicePixelRatio
	};
	const viewport = page.getViewport(params);

	// Creating the page view with default parameters.
	const pdfViewer = new pdfjsViewer.PDFPageView({
		container,
		eventBus,
		linkService,
		l10n: pdfjsViewer.NullL10n,
		defaultViewport: viewport,
	});
	// Associates the actual page with the view, and drawing it
	pdfViewer.setPdfPage(page);
	linkService.setViewer(pdfViewer);

	return pdfViewer.draw();
}