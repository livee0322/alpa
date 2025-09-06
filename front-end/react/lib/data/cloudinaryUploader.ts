import axios from 'axios';
import { apiClient } from '../apiClient';

export class CloudinaryUploader {
    private uploadApi = 'https://api.cloudinary.com/v1_1/dis1og9uq/image/upload';

    public async uploadImage(file: File, fileName?: string): Promise<string> {
        try {
            const signatureResponse = await apiClient.get<any>('/uploads/signature');
            const signatureData = signatureResponse.data || signatureResponse;

            const formData = new FormData();
            formData.append('api_key', signatureData.apiKey);
            formData.append('timestamp', signatureData.timestamp.toString());
            formData.append('signature', signatureData.signature);
            formData.append('file', file);

            if (signatureData.folder) {
                formData.append('folder', signatureData.folder);
            }

            const response = await axios.post(this.uploadApi, formData);

            if (response.status >= 200 && response.status < 300) {
                const json = response.data;
                if (!json.secure_url) {
                    throw new Error('Image URL not found in response');
                }
                return json.secure_url;
            } else {
                throw new Error(response.data?.error?.message || 'Cloudinary upload failed');
            }
        } catch (e: any) {
            console.error('Image upload failed:', e);
            throw new Error(e.message || 'Image upload failed');
        }
    }
}