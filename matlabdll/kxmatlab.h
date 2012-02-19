
# ifndef KDB_MATLAB_HPP_KKT_18_02_2012
# define KDB_MATLAB_HPP_KKT_18_02_2012

# include <kdb/kdb.hpp>
# include <engine.h> // this is the header file for the matlab
# include <cstdint>

/*
Here we need to implement 5 functions 
	K mxOpen (K k) return the Engine* as int
	K mxClose(K k) return nothing
	K mxput  (K k1, K k2, K k3) 
	K mxGet  (K k1, K k2)
	K mxEval (K k1, K k2)
*/

namespace kx {
	
	typedef int uintptr_t;

	K mxOpen(K kp)
	{
		kx::H t = kp->t;
		if(t!=-6) return ki(0);

		uintptr_t p = value<qtype::int_>(kp);
		Engine* ep = engOpen("\\" + p);
		// we need a way to choose the correct type
		int ptr = (ep==NULL) ? 0 : reinterpret_cast<int>(ep) ;
		return kx::ki(ptr);
	}

	K mxClose(K mxp)
	{
		uintptr_t p = value<qtype::int_>(mxp);
		if(p==0) return kb(0);
		int r = engClose(reinterpret_cast<Engine*>(p));
		return kb(r);
	}

	K mxEval(K mx,K cmd)
	{
		uintptr_t p = value<qtype::int_>(mx);
		if(p==0) return kb(0);
		Engine* ep = reinterpret_cast<Engine*>(p);
		kx::vector<qtype::char_> vc(cmd);
		std::string str(vc.begin(),vc.end());
		int r = engEvalString(ep, str.c_str());

		return kb(r);

	}

	K mxGet(K mx,K var)
	{
		uintptr_t p = value<qtype::int_>(mx);
		if(p==0) return kb(0);
		mxArray *T = NULL;
		Engine* ep = reinterpret_cast<Engine*>(p);

		kx::vector<qtype::char_> vc(var);
		std::string str(vc.begin(),vc.end());
		T = engGetVariable(ep, str.c_str());
		
		//std::string str(vc.begin(),vc.end());

		if(T==NULL) return kb(0);
		if(mxGetClassID(T)!=mxDOUBLE_CLASS) return kb(0);
		mwSize ndim = mxGetNumberOfDimensions(T);
		if(ndim>3) return kb(0);
		mwSize const* dims = mxGetDimensions(T);

		std::vector<mwSize> mwv(dims,dims+ndim);
		double* mxf = mxGetPr(T);
//		std::vector<double> elm(mxGetPr(T),mxGetPr(T)+);
		if(mwv[0]==1)
		{
			vector<qtype::float_> kv(mxGetNumberOfElements(T));
			std::copy(mxf,mxf+mxGetNumberOfElements(T),kv.begin());
			return kv;
		}
		else
		{
			int end = mwv[0];
			int l = mwv[1];
			K k = knk(end);

			for( int i = 0;i!=end;++i)
			{
				vector<qtype::float_> kv(l);
				int j = 0;
				for(vector<qtype::float_>::iterator it=kv.begin(),iend=kv.end();it!=iend;++it)
				{
					(*it)=mxf[i+j*end];
					++j;
					
				}
				((K*)k->G0)[i]=kv();
			}
			return k;
		}

	}

	K mxPut(K mx,K var,K k)
	{
		uintptr_t p = value<qtype::int_>(mx);
		if(p==0) return kb(0);
		mxArray *T = NULL;
		Engine* ep = reinterpret_cast<Engine*>(p);

		kx::vector<qtype::char_> vc(var);
		std::string nme(vc.begin(),vc.end());

		// we need to distinguish between list and matrix
		if(k->t == 0)
		{
			int n = k->n;
			K kf = ((K*)k->G0)[0];
			
			if(kf->t!=9) return ki(0);
			int m = kf->n;
			T = mxCreateDoubleMatrix(n,m, mxREAL);
			double* mxf = mxGetPr(T);
			for(int i = 0;i<n;++i)
			{
				vector<qtype::float_> qvec(((K*)k->G0)[i]);
				int j = 0;
				for(vector<qtype::float_>::iterator it=qvec.begin(),iend=qvec.end();it!=iend;++it)
				{
					mxf[i+j*n]=(*it);
					++j;	
				}
			}
			engPutVariable(ep, nme.c_str(), T);
			//T = mxCreateDoubleMatrix(1, qvec.size(), mxREAL);
			//std::copy(qvec.begin(),qvec.end(),mxGetPr(T));
			//engPutVariable(ep, nme.c_str(), T);
			return ki(1);
		}

		if(k->t == -9)
		{
			T = mxCreateDoubleMatrix(1, 1, mxREAL);
			double val = value<qtype::float_>(k);
			std::vector<double> vec (1,val);
			std::copy(vec.begin(),vec.end(),mxGetPr(T));
			engPutVariable(ep, nme.c_str(), T);
			return ki(1);
		}

		if(k->t == 9)
		{
			vector<qtype::float_> qvec(k);
			T = mxCreateDoubleMatrix(1, qvec.size(), mxREAL);
			std::copy(qvec.begin(),qvec.end(),mxGetPr(T));
			engPutVariable(ep, nme.c_str(), T);
			return ki(1);
		}

		return k;

//		T = engGetVariable(ep, str.c_str());
//		
//		//std::string str(vc.begin(),vc.end());
//
//		if(T==NULL) return kb(0);
//		if(mxGetClassID(T)!=mxDOUBLE_CLASS) return kb(0);
//		mwSize ndim = mxGetNumberOfDimensions(T);
//		if(ndim>3) return kb(0);
//		mwSize const* dims = mxGetDimensions(T);
//
//		std::vector<mwSize> mwv(dims,dims+ndim);
//		double* mxf = mxGetPr(T);
////		std::vector<double> elm(mxGetPr(T),mxGetPr(T)+);
//		if(mwv[0]==1)
//		{
//			vector<qtype::float_> kv(mxGetNumberOfElements(T));
//			std::copy(mxf,mxf+mxGetNumberOfElements(T),kv.begin());
//			return kv;
//		}
//		else
//		{
//			int end = mwv[0];
//			int l = mwv[1];
//			K k = knk(end);
//
//			for( int i = 0;i!=end;++i)
//			{
//				vector<qtype::float_> kv(l);
//				int j = 0;
//				for(vector<qtype::float_>::iterator it=kv.begin(),iend=kv.end();it!=iend;++it)
//				{
//					(*it)=mxf[i+j*end];
//					++j;
//					
//				}
//				((K*)k->G0)[i]=kv();
//			}
//			return k;
		}

} // matlab



# endif KDBMATLAB_HPP_KKT_18_02_2012