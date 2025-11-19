import { createClient } from '@supabase/supabase-js';

const supabase = createClient(process.env.NEXT_PUBLIC_SUPABASE_URL!, process.env.SUPABASE_SERVICE_ROLE_KEY!);

export default async function handler(req, res) {
  const file = req.body.file;
  const { data, error } = await supabase.storage.from('benefit-icons').upload(file.name, file);
  if (error) return res.status(400).json({ error });
  const publicUrl = supabase.storage.from('benefit-icons').getPublicUrl(file.name).data.publicUrl;
  res.status(200).json({ url: publicUrl });
}
