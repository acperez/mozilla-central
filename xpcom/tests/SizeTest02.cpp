// Test02.cpp

#include "nsIDOMNode.h"
#include "nsCOMPtr.h"
#include "nsIPtr.h"

#ifdef __MWERKS__
	#pragma exceptions off
#endif

static NS_DEFINE_IID(kIDOMNodeIID, NS_IDOMNODE_IID);
NS_DEF_PTR(nsIDOMNode);

	/*
		This test file compares the generated code size of similar functions between raw
		COM interface pointers (|AddRef|ing and |Release|ing by hand), |nsCOMPtr|s, and
		the smart-pointer macro defined in "nsIPtr.h".

		Function size results were determined by examining dissassembly of the generated code.
		mXXX is the size of the generated code on the Macintosh.  wXXX is the size on Windows.
		For these tests, all reasonable optimizations were enabled and exceptions were
		disabled (just as we build for release).

		The tests in this file explore more complicated functionality: assigning a pointer
		to be reference counted into a [raw, nsCOMPtr, nsIPtr] object using |QueryInterface|;
		ensuring that it is |AddRef|ed and |Release|d appropriately; calling through the pointer
		to a function supplied by the underlying COM interface.  The tests in this file expand
		on the tests in "Test01.cpp" by adding |QueryInterface|.

		Windows:
			raw01									 52
			nsCOMPtr							 63
			raw										 66
			nsCOMPtr*							 68
			nsIPtr								 66 + 196
			

		Macintosh:
			nsCOMPtr							120 	(1.0000)
			Raw01									128		(1.1429)	i.e., 14.29% bigger than nsCOMPtr
			Raw00									144		(1.2000)
			nsIPtr								196 	(1.6333)
	*/


void // nsresult
Test02_Raw00( nsISupports* aDOMNode, nsString* aResult )
		// m144, w66
	{
// -- the following code is assumed, but is commented out so we compare only
//		 the relevent generated code

//		if ( !aDOMNode )
//			return NS_ERROR_NULL_POINTER;

		nsIDOMNode* node = 0;
		nsresult status = aDOMNode->QueryInterface(kIDOMNodeIID, (void**)&node);
		if ( NS_SUCCEEDED(status) )
			{
				node->GetNodeName(*aResult);
			}

		NS_IF_RELEASE(node);

//		return status;
	}

void // nsresult
Test02_Raw01( nsISupports* aDOMNode, nsString* aResult )
		// m128, w52
	{
//		if ( !aDOMNode )
//			return NS_ERROR_NULL_POINTER;

		nsIDOMNode* node;
		nsresult status = aDOMNode->QueryInterface(kIDOMNodeIID, (void**)&node);
		if ( NS_SUCCEEDED(status) )
			{
				node->GetNodeName(*aResult);
				NS_RELEASE(node);
			}

//		return status;
	}

void // nsresult
Test02_nsCOMPtr( nsISupports* aDOMNode, nsString* aResult )
		// m120, w63/68
	{
		nsresult status;
		nsCOMPtr<nsIDOMNode> node = do_QueryInterface(aDOMNode, &status);
		
		if ( node )
			node->GetNodeName(*aResult);

//		return status;
	}

void // nsresult
Test02_nsIPtr( nsISupports* aDOMNode, nsString* aResult )
		// m196, w66
	{
//		if ( !aDOMNode )
//			return NS_ERROR_NULL_POINTER;

		nsIDOMNodePtr node;
		nsresult status = aDOMNode->QueryInterface(kIDOMNodeIID, node.Query());

		if ( NS_SUCCEEDED(status) )
			node->GetNodeName(*aResult);

//		return status;
	}
